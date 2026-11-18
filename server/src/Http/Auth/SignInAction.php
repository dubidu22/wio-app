<?php

declare(strict_types=1);

namespace Wio\Http\Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\SignIn;
use Wio\Auth\SignInResult;
use Wio\Http\InvalidRequest;
use Wio\Http\Json;
use Wio\Http\Problem;

/**
 * POST /auth/sign-in (signIn). The body is checked here against the closed
 * SignInRequest schema, because the contract is not loaded at run time
 * (D-93); the api tests prove both agree.
 */
final class SignInAction
{
    private const string UUID = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';

    /** @var array<string, array{int, int}> field => [min, max] length */
    private const array FIELDS = [
        'email' => [3, 254],
        'password' => [1, 1024],
        'device_name' => [1, 100],
    ];

    /**
     * @param \Closure(): SignIn $signIn
     */
    public function __construct(private readonly \Closure $signIn) {}

    public function __invoke(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $body = self::body($request);
        $server = $request->getServerParams();
        $ip = \is_string($server['REMOTE_ADDR'] ?? null) ? $server['REMOTE_ADDR'] : '';

        $result = ($this->signIn)()->attempt($body['email'], $body['password'], $body['device_name'], $body['workspace_id'], $ip);

        return match ($result->kind) {
            SignInResult::SIGNED_IN => Json::write($response, $result->signedIn ?? []),
            SignInResult::CHOOSE => Problem::write(
                $response,
                409,
                'workspace_choice_required',
                'Choose a workspace',
                'This e-mail and password belong to several workspaces; sign in again with one workspace_id.',
                ['workspaces' => $result->workspaces],
            ),
            SignInResult::LIMITED => Problem::write($response, 429, 'too_many_attempts', 'Too many attempts')
                ->withHeader('Retry-After', (string) $result->retryAfter),
            default => Problem::write($response, 401, 'invalid_credentials', 'Wrong e-mail or password'),
        };
    }

    /**
     * @return array{email: string, password: string, device_name: string, workspace_id: ?string}
     */
    private static function body(ServerRequestInterface $request): array
    {
        $type = strtolower(trim(explode(';', $request->getHeaderLine('Content-Type'))[0]));
        if ($type !== 'application/json') {
            throw new InvalidRequest('The body must be application/json.');
        }
        try {
            $body = json_decode((string) $request->getBody(), true, 8, JSON_THROW_ON_ERROR);
        } catch (\JsonException) {
            throw new InvalidRequest('The body is not valid JSON.');
        }
        if (!\is_array($body) || array_is_list($body) && $body !== []) {
            throw new InvalidRequest('The body must be a JSON object.');
        }

        $unknown = array_diff(array_map('strval', array_keys($body)), [...array_keys(self::FIELDS), 'workspace_id']);
        if ($unknown !== []) {
            throw new InvalidRequest('Unknown field: ' . self::fieldName(array_values($unknown)[0]));
        }


        $workspaceId = $body['workspace_id'] ?? null;
        if ($workspaceId !== null && (!\is_string($workspaceId) || preg_match(self::UUID, $workspaceId) !== 1)) {
            throw new InvalidRequest('workspace_id must be a UUID.');
        }

        return [
            'email' => self::text($body, 'email'),
            'password' => self::text($body, 'password'),
            'device_name' => self::text($body, 'device_name'),
            'workspace_id' => $workspaceId === null ? null : strtolower($workspaceId),
        ];
    }

    /**
     * @param array<mixed> $body
     */
    private static function text(array $body, string $field): string
    {
        [$min, $max] = self::FIELDS[$field];
        $value = $body[$field] ?? null;
        if (!\is_string($value)) {
            throw new InvalidRequest("{$field} is required and must be a string.");
        }
        $length = mb_strlen($value, 'UTF-8');
        if ($length < $min || $length > $max) {
            throw new InvalidRequest("{$field} must have {$min} to {$max} characters.");
        }

        return $value;
    }

    /**
     * A field name for the error detail: shown only when it is a plain
     * identifier, never an arbitrary submitted string.
     */
    private static function fieldName(string $name): string
    {
        return preg_match('/^[a-z_]{1,40}$/', $name) === 1 ? $name : '(not shown)';
    }
}
