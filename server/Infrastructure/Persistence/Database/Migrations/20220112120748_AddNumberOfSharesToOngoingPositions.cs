using Microsoft.EntityFrameworkCore.Migrations;

namespace Infrastructure.Persistence.Database.Migrations;

public partial class AddNumberOfSharesToOngoingPositions : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<int>(
            name: "NumberOfShares",
            table: "OngoingWarrantPositions",
            type: "int",
            nullable: false,
            defaultValue: 0);

        migrationBuilder.AddColumn<int>(
            name: "NumberOfShares",
            table: "OngoingKnockoutPositions",
            type: "int",
            nullable: false,
            defaultValue: 0);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "NumberOfShares",
            table: "OngoingWarrantPositions");

        migrationBuilder.DropColumn(
            name: "NumberOfShares",
            table: "OngoingKnockoutPositions");
    }
}