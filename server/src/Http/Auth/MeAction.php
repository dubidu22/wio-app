<?php

declare(strict_types=1);

namespace Wio\Http\Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use RuntimeException;
use Wio\Auth\AuthContext;
use Wio\Database\Sql;
use Wio\Http\Json;

/**
 * GET /auth/me (getMe): the caller's user and workspace.
 */
final class MeAction
{
    /**
     * @param \Closure(): Sql $sql
     */
    public function __construct(private readonly \Closure $sql) {}

    public function __invoke(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $caller = AuthContext::of($request);
        $row = ($this->sql)()->row(
            'SELECT u.display_name, w.name, w.plan FROM users u JOIN workspaces w ON w.id = u.workspace_id
             WHERE u.workspace_id = ? AND u.id = ?',
            [$caller->workspaceId, $caller->userId],
        );
        if ($row === null) {
            throw new RuntimeException('The caller vanished after the token check.');
        }

        return Json::write($response, [
            'device_id' => $caller->deviceId,
            'user' => ['id' => $caller->userId, 'role' => $caller->role, 'display_name' => Sql::textOrNull($row['display_name'])],
            'workspace' => ['id' => $caller->workspaceId, 'name' => Sql::textOrNull($row['name']), 'plan' => Sql::text($row['plan'])],
        ]);
    }
}
