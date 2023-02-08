using Microsoft.EntityFrameworkCore.Migrations;

namespace Infrastructure.Persistence.Database.Migrations;

public partial class AddInitialBalanceToUser : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<decimal>(
            name: "InitialBalance",
            table: "Portfolios",
            type: "decimal(18,2)",
            nullable: false,
            defaultValue: 0m);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "InitialBalance",
            table: "Portfolios");
    }
}