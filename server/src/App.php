<?php

declare(strict_types=1);

namespace Wio;

use Psr\Container\ContainerInterface;
use Slim\App as SlimApp;
use Slim\Factory\AppFactory;
use Wio\Http\HealthAction;

/**
 * Builds the HTTP application. Routes follow api/openapi.yaml, the only
 * contract between the app and the server (INV-02).
 */
final class App
{
    /**
     * @return SlimApp<ContainerInterface|null>
     */
    public static function create(): SlimApp
    {
        $app = AppFactory::create();
        $app->addRoutingMiddleware();
        $app->addErrorMiddleware(false, false, false);

        $app->get('/health', new HealthAction());

        return $app;
    }

    private function __construct() {}
}
