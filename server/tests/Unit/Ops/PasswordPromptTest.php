<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Ops;

use PHPUnit\Framework\TestCase;
use Wio\Ops\OpsException;
use Wio\Ops\PasswordPrompt;

/**
 * The ops scripts read the password from standard input and never echo it
 * at a terminal (D-115).
 */
final class PasswordPromptTest extends TestCase
{
    /** @var list<bool> */
    private array $echo = [];

    public function testPipedInputIsTheFirstLine(): void
    {
        self::assertSame('ein-langes-passwort', $this->prompt("ein-langes-passwort\r\nzweite Zeile\n", false)[0]->read());
        self::assertSame([], $this->echo, 'no terminal, no stty');
    }

    public function testAtATerminalEchoIsOffWhileTypingTwice(): void
    {
        [$prompt, $questions] = $this->prompt("ein-langes-passwort\nein-langes-passwort\n", true);

        self::assertSame('ein-langes-passwort', $prompt->read());
        self::assertSame([false, true], $this->echo, 'echo off, then on again');
        self::assertStringNotContainsString('ein-langes-passwort', (string) stream_get_contents($questions, offset: 0));
    }

    public function testTwoDifferentAnswersAreRefusedAndEchoComesBack(): void
    {
        try {
            $this->prompt("eins-eins-eins\nzwei-zwei-zwei\n", true)[0]->read();
            self::fail('accepted two different passwords');
        } catch (OpsException $e) {
            self::assertStringNotContainsString('eins', $e->getMessage());
        }
        self::assertSame([false, true], $this->echo);
    }

    public function testATerminalThatCannotHideInputIsRefused(): void
    {
        $this->expectException(OpsException::class);

        $this->prompt("ein-langes-passwort\n", true, false)[0]->read();
    }

    public function testEmptyInputIsRefused(): void
    {
        $this->expectException(OpsException::class);

        $this->prompt('', false)[0]->read();
    }

    /**
     * @return array{PasswordPrompt, resource} the prompt and the stream its questions go to
     */
    private function prompt(string $input, bool $terminal, bool $canHide = true): array
    {
        $in = fopen('php://memory', 'w+');
        $out = fopen('php://memory', 'w+');
        self::assertIsResource($in);
        self::assertIsResource($out);
        fwrite($in, $input);
        rewind($in);
        return [new PasswordPrompt($in, $out, $terminal, function (bool $on) use ($canHide): bool {
            if (!$canHide) {
                return false;
            }
            $this->echo[] = $on;

            return true;
        }), $out];
    }
}
