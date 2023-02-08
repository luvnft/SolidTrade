using Microsoft.EntityFrameworkCore.Migrations;

namespace Infrastructure.Persistence.Database.Migrations;

public partial class RemoveOngoingProduct : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropForeignKey(
            name: "FK_OngoingKnockoutPositions_KnockoutPositions_CurrentKnockoutPositionId",
            table: "OngoingKnockoutPositions");

        migrationBuilder.DropForeignKey(
            name: "FK_OngoingWarrantPositions_WarrantPositions_CurrentWarrantPositionId",
            table: "OngoingWarrantPositions");

        migrationBuilder.DropIndex(
            name: "IX_OngoingWarrantPositions_CurrentWarrantPositionId",
            table: "OngoingWarrantPositions");

        migrationBuilder.DropIndex(
            name: "IX_OngoingKnockoutPositions_CurrentKnockoutPositionId",
            table: "OngoingKnockoutPositions");

        migrationBuilder.DropColumn(
            name: "CurrentWarrantPositionId",
            table: "OngoingWarrantPositions");

        migrationBuilder.DropColumn(
            name: "CurrentKnockoutPositionId",
            table: "OngoingKnockoutPositions");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<int>(
            name: "CurrentWarrantPositionId",
            table: "OngoingWarrantPositions",
            type: "int",
            nullable: true);

        migrationBuilder.AddColumn<int>(
            name: "CurrentKnockoutPositionId",
            table: "OngoingKnockoutPositions",
            type: "int",
            nullable: true);

        migrationBuilder.CreateIndex(
            name: "IX_OngoingWarrantPositions_CurrentWarrantPositionId",
            table: "OngoingWarrantPositions",
            column: "CurrentWarrantPositionId");

        migrationBuilder.CreateIndex(
            name: "IX_OngoingKnockoutPositions_CurrentKnockoutPositionId",
            table: "OngoingKnockoutPositions",
            column: "CurrentKnockoutPositionId");

        migrationBuilder.AddForeignKey(
            name: "FK_OngoingKnockoutPositions_KnockoutPositions_CurrentKnockoutPositionId",
            table: "OngoingKnockoutPositions",
            column: "CurrentKnockoutPositionId",
            principalTable: "KnockoutPositions",
            principalColumn: "Id",
            onDelete: ReferentialAction.Restrict);

        migrationBuilder.AddForeignKey(
            name: "FK_OngoingWarrantPositions_WarrantPositions_CurrentWarrantPositionId",
            table: "OngoingWarrantPositions",
            column: "CurrentWarrantPositionId",
            principalTable: "WarrantPositions",
            principalColumn: "Id",
            onDelete: ReferentialAction.Restrict);
    }
}