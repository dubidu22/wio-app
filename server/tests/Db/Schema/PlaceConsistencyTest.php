<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

use PHPUnit\Framework\Attributes\DataProvider;

/**
 * D-49 and the place rules of the data model: a room must be in the entry's
 * site, a fixture in its room; a slot needs a fixture; a floor point needs
 * both coordinates and excludes a fixture. Checked for the place and the
 * target place (D-9).
 */
final class PlaceConsistencyTest extends SchemaTestCase
{
    private string $workspace;
    private string $site;
    private string $room;
    private string $fixture;
    private string $otherSite;
    private string $otherRoom;
    private string $otherFixture;

    protected function setUp(): void
    {
        parent::setUp();
        $this->workspace = $this->rows->workspace('personal');
        $this->site = $this->rows->site($this->workspace, null);
        $this->room = $this->rows->room($this->workspace, $this->site, null);
        $this->fixture = $this->rows->fixture($this->workspace, $this->room, null);
        $this->otherSite = $this->rows->site($this->workspace, null);
        $this->otherRoom = $this->rows->room($this->workspace, $this->otherSite, null);
        $this->otherFixture = $this->rows->fixture($this->workspace, $this->otherRoom, null);
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function placeGroups(): iterable
    {
        yield 'place' => [''];
        yield 'target place' => ['target_'];
    }

    #[DataProvider('placeGroups')]
    public function testAValidShelfSlotAndAValidFloorPointAreAccepted(string $p): void
    {
        $this->entry($p, ['site_id' => $this->site, 'room_id' => $this->room, 'fixture_id' => $this->fixture, 'level' => 2, 'compartment' => 1]);
        $this->entry($p, ['site_id' => $this->site, 'room_id' => $this->room, 'floor_x_cm' => 120, 'floor_y_cm' => 80]);

        self::assertCount(2, $this->rowsOf('SELECT id FROM entries'));
    }

    #[DataProvider('placeGroups')]
    public function testARoomOutsideTheSiteIsRejected(string $p): void
    {
        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->entry($p, ['site_id' => $this->site, 'room_id' => $this->otherRoom]));
    }

    #[DataProvider('placeGroups')]
    public function testAFixtureOutsideTheRoomIsRejected(string $p): void
    {
        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->entry($p, [
            'site_id' => $this->site,
            'room_id' => $this->room,
            'fixture_id' => $this->otherFixture,
        ]));
    }

    #[DataProvider('placeGroups')]
    public function testASiteWithoutARoomIsRejected(string $p): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->entry($p, ['site_id' => $this->site]));
    }

    #[DataProvider('placeGroups')]
    public function testALevelWithoutAFixtureIsRejected(string $p): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->entry($p, ['site_id' => $this->site, 'room_id' => $this->room, 'level' => 1]));
    }

    #[DataProvider('placeGroups')]
    public function testLevelsAndCompartmentsCountFromOne(string $p): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->entry($p, [
            'site_id' => $this->site,
            'room_id' => $this->room,
            'fixture_id' => $this->fixture,
            'compartment' => 0,
        ]));
    }

    #[DataProvider('placeGroups')]
    public function testHalfAFloorPointIsRejected(string $p): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->entry($p, ['site_id' => $this->site, 'room_id' => $this->room, 'floor_x_cm' => 10]));
    }

    #[DataProvider('placeGroups')]
    public function testAFloorPointAndAFixtureTogetherAreRejected(string $p): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->entry($p, [
            'site_id' => $this->site,
            'room_id' => $this->room,
            'fixture_id' => $this->fixture,
            'floor_x_cm' => 10,
            'floor_y_cm' => 10,
        ]));
    }

    public function testAnEntryWithoutAPlaceIsAllowed(): void
    {
        self::assertNotSame('', $this->rows->entry($this->workspace, null, ['title' => 'Karton']));
    }

    /**
     * @param array<string, scalar> $place field => value, without prefix
     */
    private function entry(string $prefix, array $place): string
    {
        $values = [];
        foreach ($place as $field => $value) {
            $values[$prefix . $field] = $value;
        }

        return $this->rows->entry($this->workspace, null, $values);
    }
}
