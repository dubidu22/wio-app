<?php

declare(strict_types=1);

/**
 * Operations of api/openapi.yaml that the server does not implement yet, with
 * the issue that owns them (D-94). RouteParityTest fails when one of them is
 * routed (remove it here) and when an operation is neither routed nor listed.
 * Milestone M1 cannot close while this list is not empty.
 *
 * @return array<string, int> operationId => issue number in dubidu22/wio-app
 */
return [
    'signIn' => 5,
    'signOut' => 5,
    'getMe' => 5,
    'listDevices' => 5,
    'revokeDevice' => 5,
    'syncPush' => 6,
    'syncPull' => 6,
    'getFileState' => 6,
    'putFileChunk' => 6,
];
