using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class OrigenEventoSalud : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "FechaOcurrenciaEventoAgenda",
                table: "t_EventoSalud",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ID_EventoAgenda",
                table: "t_EventoSalud",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoSalud_ID_EventoAgenda",
                table: "t_EventoSalud",
                column: "ID_EventoAgenda");

            migrationBuilder.AddForeignKey(
                name: "FK_t_EventoSalud_t_EventoAgenda_ID_EventoAgenda",
                table: "t_EventoSalud",
                column: "ID_EventoAgenda",
                principalTable: "t_EventoAgenda",
                principalColumn: "ID_EventoAgenda",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_EventoSalud_t_EventoAgenda_ID_EventoAgenda",
                table: "t_EventoSalud");

            migrationBuilder.DropIndex(
                name: "IX_t_EventoSalud_ID_EventoAgenda",
                table: "t_EventoSalud");

            migrationBuilder.DropColumn(
                name: "FechaOcurrenciaEventoAgenda",
                table: "t_EventoSalud");

            migrationBuilder.DropColumn(
                name: "ID_EventoAgenda",
                table: "t_EventoSalud");
        }
    }
}
