using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class AgregadoFechaEliminacionActivacionCuidado : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "FechaEliminacion",
                table: "t_AsignacionCuidado",
                type: "datetime2",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FechaEliminacion",
                table: "t_AsignacionCuidado");
        }
    }
}
