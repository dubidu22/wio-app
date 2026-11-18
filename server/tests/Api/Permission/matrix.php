<?php

declare(strict_types=1);

/**
 * The permission matrix (KB data-model.md, rights per role; D-13, D-117):
 * the status each caller gets from each operation. PermissionMatrixTest
 * checks every cell and fails when a routed operation has no row. It runs as
 * the PHPUnit suite `permission`, its own CI step (#13, D-138); #6 and M6 add
 * rows. This file is the repository's copy of the KB rights table (D-13): CI
 * cannot read the private KB, so reviews check new rows against it (D-139).
 *
 * Callers: anonymous (no token, or an e-mail nobody has), owner, customer,
 * helper, expired_helper (a helper whose link has passed), other_workspace
 * (a valid owner token of a second workspace). Token operations act on the
 * caller's own device, except that other_workspace aims revokeDevice at a
 * device of the first workspace's owner. signIn uses the caller's own e-mail
 * and password (customers and helpers get one only in this test, to prove
 * they still cannot sign in before M6).
 *
 * A row named "<operation> result" holds what the body says where the status
 * alone does not tell (the push result's status or reason).
 *
 * @return array<string, array{anonymous: int|string, owner: int|string, customer: int|string, helper: int|string, expired_helper: int|string, other_workspace: int|string}>
 */
return [
    'getHealth' => ['anonymous' => 200, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 200, 'other_workspace' => 200],
    'signIn' => ['anonymous' => 401, 'owner' => 200, 'customer' => 401, 'helper' => 401, 'expired_helper' => 401, 'other_workspace' => 200],
    'signOut' => ['anonymous' => 401, 'owner' => 204, 'customer' => 204, 'helper' => 204, 'expired_helper' => 401, 'other_workspace' => 204],
    'getMe' => ['anonymous' => 401, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 401, 'other_workspace' => 200],
    'listDevices' => ['anonymous' => 401, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 401, 'other_workspace' => 200],
    'revokeDevice' => ['anonymous' => 401, 'owner' => 204, 'customer' => 204, 'helper' => 204, 'expired_helper' => 401, 'other_workspace' => 404],
    // A push of one label: answered 200 with one result per change; the
    // result says applied or rejected (permission), as the next row shows
    // (D-181). Rights per entity and op: tests/Api/Sync/RightsTest.php.
    'syncPush' => ['anonymous' => 401, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 401, 'other_workspace' => 200],
    'syncPush result' => ['anonymous' => 401, 'owner' => 'applied', 'customer' => 'permission', 'helper' => 'permission', 'expired_helper' => 401, 'other_workspace' => 'applied'],
    // Scope per role (D-182): tests/Api/Sync/PullScopeTest.php.
    'syncPull' => ['anonymous' => 401, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 401, 'other_workspace' => 200],
];
