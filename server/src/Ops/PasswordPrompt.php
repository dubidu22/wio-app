<?php

declare(strict_types=1);

namespace Wio\Ops;

/**
 * Reads a password for the ops scripts from standard input, never from argv
 * or the environment, which shell history and process lists keep (D-115).
 * At a terminal the password is typed twice with echo turned off; if echo
 * cannot be turned off, the script refuses instead of showing it.
 */
final class PasswordPrompt
{
    /**
     * @param resource $input
     * @param resource $prompt where the questions go (standard error)
     * @param \Closure(bool): bool $setEcho turns terminal echo on or off; false when it cannot
     */
    public function __construct(
        private readonly mixed $input,
        private readonly mixed $prompt,
        private readonly bool $isTerminal,
        private readonly \Closure $setEcho,
    ) {}

    public static function standardInput(): self
    {
        return new self(
            STDIN,
            STDERR,
            stream_isatty(STDIN),
            static function (bool $on): bool {
                $output = [];
                $code = 1;
                // Only a fixed command; nothing from the operator reaches the shell.
                @exec($on ? 'stty echo 2>/dev/null' : 'stty -echo 2>/dev/null', $output, $code);

                return $code === 0;
            },
        );
    }

    public function read(): string
    {
        if (!$this->isTerminal) {
            return $this->line();
        }
        if (!($this->setEcho)(false)) {
            throw new OpsException('Cannot hide the password at this terminal; pipe it in instead, for example from a file: < password.txt');
        }
        try {
            fwrite($this->prompt, 'Password: ');
            $first = $this->line();
            fwrite($this->prompt, "\nPassword again: ");
            $second = $this->line();
            fwrite($this->prompt, "\n");
        } finally {
            ($this->setEcho)(true);
        }
        if (!hash_equals($first, $second)) {
            throw new OpsException('The two passwords differ.');
        }

        return $first;
    }

    private function line(): string
    {
        $line = fgets($this->input);
        if ($line === false) {
            throw new OpsException('No password on standard input.');
        }

        return rtrim($line, "\r\n");
    }
}
