<?php

declare(strict_types=1);

namespace Wio\Database;

use PDO;
use PDOStatement;
use RuntimeException;

/**
 * Small helpers over PDO prepared statements; values are always bound, never
 * written into SQL.
 */
final class Sql
{
    public function __construct(public readonly PDO $pdo) {}

    /**
     * @param list<scalar|null> $values
     */
    public function run(string $sql, array $values = []): PDOStatement
    {
        $statement = $this->pdo->prepare($sql);
        if ($statement === false) {
            throw new RuntimeException('Cannot prepare a statement.');
        }
        $statement->execute($values);

        return $statement;
    }

    /**
     * @param list<scalar|null> $values
     *
     * @return list<array<string, mixed>>
     */
    public function rows(string $sql, array $values = []): array
    {
        /** @var list<array<string, mixed>> */
        return $this->run($sql, $values)->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * @param list<scalar|null> $values
     *
     * @return array<string, mixed>|null
     */
    public function row(string $sql, array $values = []): ?array
    {
        return $this->rows($sql, $values)[0] ?? null;
    }

    /**
     * Runs $work in one transaction and commits, or rolls back and rethrows.
     *
     * @template T
     *
     * @param callable(): T $work
     *
     * @return T
     */
    public function transaction(callable $work): mixed
    {
        $this->pdo->beginTransaction();
        try {
            $result = $work();
            $this->pdo->commit();

            return $result;
        } catch (\Throwable $e) {
            if ($this->pdo->inTransaction()) {
                $this->pdo->rollBack();
            }
            throw $e;
        }
    }

    public static function text(mixed $value): string
    {
        if (!\is_string($value)) {
            throw new RuntimeException('Expected a string column.');
        }

        return $value;
    }

    public static function textOrNull(mixed $value): ?string
    {
        return $value === null ? null : self::text($value);
    }
}
