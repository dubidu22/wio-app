<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Sync;

use PHPUnit\Framework\TestCase;
use Symfony\Component\Yaml\Yaml;
use Wio\Sync\RecordSchemaGenerator;
use Wio\Sync\RecordSchemas;
use Wio\Tests\Api\Contract\RecordSchemas as ContractRecordSchemas;

/**
 * Plan 006 test P15 (D-177): the server's copy of the record schemas equals
 * a fresh generation from api/openapi.yaml, the way the client freshness
 * step works for the app.
 */
final class RecordSchemasTest extends TestCase
{
    private const string CONTRACT = __DIR__ . '/../../../../api/openapi.yaml';

    private const string FILE = __DIR__ . '/../../../src/Sync/RecordSchemas.php';

    public function testTheCommittedFileEqualsAFreshGeneration(): void
    {
        $contract = Yaml::parseFile(self::CONTRACT);
        self::assertIsArray($contract);

        self::assertSame(
            (new RecordSchemaGenerator($contract))->source(),
            file_get_contents(self::FILE),
            'api/openapi.yaml changed: run server/bin/generate-record-schemas and commit src/Sync/RecordSchemas.php',
        );
    }

    public function testEverySyncedEntityIsCovered(): void
    {
        self::assertSame(ContractRecordSchemas::BY_TABLE, RecordSchemaGenerator::SCHEMA_BY_ENTITY);
        self::assertSame(array_keys(ContractRecordSchemas::BY_TABLE), array_keys(RecordSchemas::FIELDS));
    }

    public function testReferencesAreResolvedAndTheHoldersNullableKept(): void
    {
        $outline = RecordSchemas::FIELDS['rooms']['outline'];

        self::assertSame(
            ['type' => 'array', 'nullable' => true, 'items' => ['type' => 'object', 'properties' => ['x_cm' => ['type' => 'integer', 'format' => 'int32'], 'y_cm' => ['type' => 'integer', 'format' => 'int32']], 'required' => ['x_cm', 'y_cm']]],
            $outline,
        );
        self::assertSame([], RecordSchemas::FIELDS['conflicts']['lost_value'], 'any value');
    }
}
