<?php

declare(strict_types=1);

/**
 * The permission matrix (KB data-model.md, rights per role; D-13, D-117):
 * the status each caller gets from each operation. PermissionMatrixTest
 * checks every cell and fails when a routed operation has no row. #13 runs
 * it as its own CI step; #6 and M6 add rows.
 *
 * Callers: anonymous (no token, or an e-mail nobody has), owner, customer,
 * helper, expired_helper (a helper whose link has passed). Token operations
 * act on the caller's own device; signIn uses the caller's own e-mail and
 * password (customers and helpers get one only in this test, to prove they
 * still cannot sign in before M6).
 *
 * @return array<string, array{anonymous: int, owner: int, customer: int, helper: int, expired_helper: int}>
 */
return [
    'getHealth' => ['anonymous' => 200, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 200],
    'signIn' => ['anonymous' => 401, 'owner' => 200, 'customer' => 401, 'helper' => 401, 'expired_helper' => 401],
    'signOut' => ['anonymous' => 401, 'owner' => 204, 'customer' => 204, 'helper' => 204, 'expired_helper' => 401],
    'getMe' => ['anonymous' => 401, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 401],
    'listDevices' => ['anonymous' => 401, 'owner' => 200, 'customer' => 200, 'helper' => 200, 'expired_helper' => 401],
    'revokeDevice' => ['anonymous' => 401, 'owner' => 204, 'customer' => 204, 'helper' => 204, 'expired_helper' => 401],
];
