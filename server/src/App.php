<?php

declare(strict_types=1);

namespace Wio;

use Psr\Container\ContainerInterface;
use Slim\App as SlimApp;
use Slim\Factory\AppFactory;
use Wio\Auth\AuthMiddleware;
use Wio\Http\Auth\ListDevicesAction;
use Wio\Http\Auth\MeAction;
use Wio\Http\Auth\RevokeDeviceAction;
use Wio\Http\Auth\SignInAction;
use Wio\Http\Auth\SignOutAction;
use Wio\Http\HealthAction;
use Wio\Http\ProblemErrorHandler;

/**
 * Builds the HTTP application. Routes follow api/openapi.yaml, the only
 * contract between the app and the server (INV-02). Every route except the
 * contract's public operations (`security: []`) goes through the auth
 * middleware (D-112).
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
        $app->addRoutingMiddleware();
        $app->addErrorMiddleware(false, false, false)
            ->setDefaultErrorHandler(new ProblemErrorHandler($app->getResponseFactory(), $services->log));

        // Public operations (security: [] in the contract).
        $app->get('/health', new HealthAction());
        $app->post('/auth/sign-in', new SignInAction($services->signIn(...)));

        $tokens = $services->deviceTokens(...);
        $auth = new AuthMiddleware($tokens, $app->getResponseFactory());
        $app->post('/auth/sign-out', new SignOutAction($tokens))->add($auth);
        $app->get('/auth/me', new MeAction($services->sql(...)))->add($auth);
        $app->get('/auth/devices', new ListDevicesAction($tokens))->add($auth);
        $app->delete('/auth/devices/{device_id}', new RevokeDeviceAction($tokens))->add($auth);

        return $app;
    }

    private function __construct() {}
}
