<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Contract;

use cebe\openapi\spec\Schema;
use League\OpenAPIValidation\Schema\Exception\SchemaMismatch;
use League\OpenAPIValidation\Schema\SchemaValidator;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wio\Tests\Api\Contract;

/**
 * The files in api/examples/ are true to the contract, and the files in
 * api/examples/invalid/ are not. The app's round-trip test reads the same
 * files, so both sides prove they read the same bytes (plan 004, test 5).
 *
 * File name: <request|response>.<Schema>.<case>.json
 */
final class ContractExamplesTest extends TestCase
{
    /**
     * The property each invalid example must fail on, so a typo elsewhere in
     * the file cannot make it fail for another reason.
     */
    private const array INVALID_PROPERTY = [
        'request.PushRequest.read-only-field' => 'revision',
        'request.PushRequest.unknown-op' => 'op',
        'request.PushRequest.wrong-field-type' => 'height_cm',
        'request.SignInRequest.unknown-field' => 'remember_me',
        'response.Problem.minimum-app-version-with-build' => 'minimum_app_version',
        'response.PullResult.revision-above-2-53' => 'last_revision',
    ];

    /**
     * @return iterable<string, array{string}>
     */
    public static function validExamples(): iterable
    {
        foreach (self::files(Contract::EXAMPLES . '/*.json') as $name => $file) {
            yield $name => [$file];
        }
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function invalidExamples(): iterable
    {
        foreach (self::files(Contract::EXAMPLES . '/invalid/*.json') as $name => $file) {
            yield $name => [$file];
        }
    }

    #[DataProvider('validExamples')]
    public function testExampleMatchesTheContract(string $file): void
    {
        self::assertIsArray($this->check($file));
    }

    #[DataProvider('invalidExamples')]
    public function testInvalidExampleIsRejected(string $file): void
    {
        $name = basename($file, '.json');
        self::assertArrayHasKey($name, self::INVALID_PROPERTY, "{$name}: name the property it must fail on");
        $property = self::INVALID_PROPERTY[$name];

        try {
            $this->check($file);
        } catch (SchemaMismatch $e) {
            $chain = $e->dataBreadCrumb()?->buildChain() ?? [];
            $where = $e->getMessage() . ' at ' . implode('.', array_map(static fn(mixed $step): string => \is_scalar($step) ? (string) $step : '~', $chain));
            self::assertTrue(
                \in_array($property, $chain, true)
                    || preg_match('/additional properties \\([^)]*\\b' . preg_quote($property, '/') . '\\b[^)]*\\)/', $e->getMessage()) === 1,
                "{$name} must fail on {$property}, but failed with: {$where}",
            );

            return;
        }
        self::fail("{$name} was accepted");
    }

    public function testThereAreExamplesOfBothKinds(): void
    {
        self::assertGreaterThanOrEqual(10, \count(iterator_to_array(self::validExamples())));
        self::assertGreaterThanOrEqual(3, \count(iterator_to_array(self::invalidExamples())));
    }

    public function testExamplesUseOnlyInventedAddresses(): void
    {
        foreach ([...self::files(Contract::EXAMPLES . '/*.json'), ...self::files(Contract::EXAMPLES . '/invalid/*.json')] as $name => $file) {
            $text = (string) file_get_contents($file);
            preg_match_all('/[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+)/', $text, $m);
            foreach ($m[1] as $domain) {
                self::assertSame('example.org', $domain, "{$name}: e-mail addresses use example.org (INV-07)");
            }
            preg_match_all('/\b(\d{5}) [A-ZÄÖÜ][a-zäöüß]+/u', $text, $m);
            foreach ($m[1] as $postalCode) {
                self::assertSame('00000', $postalCode, "{$name}: addresses use postal code 00000 (INV-07)");
            }
        }
    }

    /**
     * Validates one example and returns its decoded body.
     */
    private function check(string $file): mixed
    {
        [$direction, $schemaName] = explode('.', basename($file));
        $data = json_decode((string) file_get_contents($file), true, flags: JSON_THROW_ON_ERROR);
        $mode = $direction === 'request' ? SchemaValidator::VALIDATE_AS_REQUEST : SchemaValidator::VALIDATE_AS_RESPONSE;

        (new SchemaValidator($mode))->validate($data, new Schema(RecordFields::inline(Contract::schema($schemaName))));

        $body = Contract::map($data);
        if ($schemaName === 'PullResult') {
            foreach ((array) ($body['records'] ?? []) as $record) {
                $record = Contract::map($record);
                RecordFields::checkPulled(Contract::text($record['entity'] ?? null), Contract::map($record['fields'] ?? null));
            }
        }
        if ($schemaName === 'PushRequest') {
            foreach ((array) ($body['changes'] ?? []) as $change) {
                $change = Contract::map($change);
                RecordFields::checkPushed(Contract::text($change['entity'] ?? null), Contract::text($change['op'] ?? null), Contract::map($change['fields'] ?? null));
            }
        }

        return $data;
    }

    /**
     * @return array<string, string> case name => path
     */
    private static function files(string $pattern): array
    {
        $files = [];
        $found = glob($pattern);
        foreach ($found === false ? [] : $found as $file) {
            $files[basename($file, '.json')] = $file;
        }
        ksort($files);

        return $files;
    }
}
