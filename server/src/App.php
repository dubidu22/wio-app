<?php

declare(strict_types=1);

namespace Wio;

use Psr\Container\ContainerInterface;
use Slim\App as SlimApp;
use Slim\Factory\AppFactory;
use Wio\AppVersion\AppVersionMiddleware;
use Wio\Auth\AuthMiddleware;
use Wio\Http\Auth\ListDevicesAction;
use Wio\Http\Auth\MeAction;
use Wio\Http\Auth\RevokeDeviceAction;
use Wio\Http\Auth\SignInAction;
use Wio\Http\Auth\SignOutAction;
use Wio\Http\CorsMiddleware;
use Wio\Http\Files\FileStateAction;
use Wio\Http\Files\PutFileChunkAction;
use Wio\Http\HealthAction;
use Wio\Http\ProblemErrorHandler;
use Wio\Http\Sync\PullAction;
use Wio\Http\Sync\PushAction;

/**
 * Builds the HTTP application. Routes follow api/openapi.yaml, the only
 * contract between the app and the server (INV-02). Every route except the
 * contract's public operations (`security: []`) goes through the auth
 * middleware (D-112); every route goes through the app-version check first
 * (D-142). CORS wraps everything (D-168).
 */
final class App
{
    /**
     * @return SlimApp<ContainerInterface|null>
     */
    public static function create(?Services $services = null): SlimApp
    {
        $services ??= Services::fromEnvironment();
        $app = AppFactory::create();
        // Runs after routing and before every route's own middleware, so an
        // old app learns "update" before "token invalid" (D-142).
        $app->add(new AppVersionMiddleware($services->minimumAppVersion, $app->getResponseFactory()));
        $app->addRoutingMiddleware();
        $app->addErrorMiddleware(false, false, false)
            ->setDefaultErrorHandler(new ProblemErrorHandler($app->getResponseFactory(), $services->log));
        // Outermost, so problem answers from the error handler carry the
        // CORS headers too, and preflights never reach auth (D-165, D-168).
        $app->add(new CorsMiddleware($services->cors, $app->getResponseFactory(), $services->log));

        // Public operations (security: [] in the contract).
        $app->get('/health', new HealthAction());
        $app->post('/auth/sign-in', new SignInAction($services->signIn(...)));

        $tokens = $services->deviceTokens(...);
        $auth = new AuthMiddleware($tokens, $app->getResponseFactory());
        $app->post('/auth/sign-out', new SignOutAction($tokens))->add($auth);
        $app->get('/auth/me', new MeAction($services->sql(...)))->add($auth);
        $app->get('/auth/devices', new ListDevicesAction($tokens))->add($auth);
        $app->delete('/auth/devices/{device_id}', new RevokeDeviceAction($tokens))->add($auth);
        $app->post('/sync/push', new PushAction($services->push(...)))->add($auth);
        $app->get('/sync/pull', new PullAction($services->pull(...)))->add($auth);
        $app->get('/files/{sha256}/state', new FileStateAction($services->files(...)))->add($auth);
        $app->put('/files/{sha256}', new PutFileChunkAction($services->files(...)))->add($auth);

        return $app;
    }

    private function __construct() {}
}
