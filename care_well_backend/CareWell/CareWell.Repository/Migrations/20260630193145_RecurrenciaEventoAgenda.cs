using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class RecurrenciaEventoAgenda : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_EventoAgenda_t_Usuario_ID_Usuario",
                table: "t_EventoAgenda");

            migrationBuilder.DropTable(
                name: "t_EventoAgendaRecordatorio");

            migrationBuilder.RenameColumn(
                name: "ID_Usuario",
                table: "t_EventoAgenda",
                newName: "ID_Persona_Creador");

            migrationBuilder.RenameColumn(
                name: "FechaHoraFin",
                table: "t_EventoAgenda",
                newName: "FechaUltimaGeneracionEventoSalud");

            migrationBuilder.RenameIndex(
                name: "IX_t_EventoAgenda_ID_Usuario",
                table: "t_EventoAgenda",
                newName: "IX_t_EventoAgenda_ID_Persona_Creador");

            migrationBuilder.AddColumn<long>(
                name: "Duracion",
                table: "t_EventoAgenda",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<string>(
                name: "FechasExceptuadas",
                table: "t_EventoAgenda",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "GenerarEventoSalud",
                table: "t_EventoAgenda",
                type: "bit",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<int>(
                name: "MinutosAnticipacionRecordatorio",
                table: "t_EventoAgenda",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ReglaRecurrencia",
                table: "t_EventoAgenda",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_t_EventoAgenda_t_Persona_ID_Persona_Creador",
                table: "t_EventoAgenda",
                column: "ID_Persona_Creador",
                principalTable: "t_Persona",
                principalColumn: "ID_Persona",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_EventoAgenda_t_Persona_ID_Persona_Creador",
                table: "t_EventoAgenda");

            migrationBuilder.DropColumn(
                name: "Duracion",
                table: "t_EventoAgenda");

            migrationBuilder.DropColumn(
                name: "FechasExceptuadas",
                table: "t_EventoAgenda");

            migrationBuilder.DropColumn(
                name: "GenerarEventoSalud",
                table: "t_EventoAgenda");

            migrationBuilder.DropColumn(
                name: "MinutosAnticipacionRecordatorio",
                table: "t_EventoAgenda");

            migrationBuilder.DropColumn(
                name: "ReglaRecurrencia",
                table: "t_EventoAgenda");

            migrationBuilder.RenameColumn(
                name: "ID_Persona_Creador",
                table: "t_EventoAgenda",
                newName: "ID_Usuario");

            migrationBuilder.RenameColumn(
                name: "FechaUltimaGeneracionEventoSalud",
                table: "t_EventoAgenda",
                newName: "FechaHoraFin");

            migrationBuilder.RenameIndex(
                name: "IX_t_EventoAgenda_ID_Persona_Creador",
                table: "t_EventoAgenda",
                newName: "IX_t_EventoAgenda_ID_Usuario");

            migrationBuilder.CreateTable(
                name: "t_EventoAgendaRecordatorio",
                columns: table => new
                {
                    ID_EventoAgendaRecordatorio = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_EventoAgenda = table.Column<int>(type: "int", nullable: false),
                    Enviado = table.Column<bool>(type: "bit", nullable: false),
                    FechaHoraEnvio = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_EventoAgendaRecordatorio", x => x.ID_EventoAgendaRecordatorio);
                    table.ForeignKey(
                        name: "FK_t_EventoAgendaRecordatorio_t_EventoAgenda_ID_EventoAgenda",
                        column: x => x.ID_EventoAgenda,
                        principalTable: "t_EventoAgenda",
                        principalColumn: "ID_EventoAgenda",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoAgendaRecordatorio_ID_EventoAgenda",
                table: "t_EventoAgendaRecordatorio",
                column: "ID_EventoAgenda");

            migrationBuilder.AddForeignKey(
                name: "FK_t_EventoAgenda_t_Usuario_ID_Usuario",
                table: "t_EventoAgenda",
                column: "ID_Usuario",
                principalTable: "t_Usuario",
                principalColumn: "ID_Usuario",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
