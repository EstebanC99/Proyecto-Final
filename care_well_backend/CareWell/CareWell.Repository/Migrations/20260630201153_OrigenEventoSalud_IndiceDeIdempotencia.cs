using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class OrigenEventoSalud_IndiceDeIdempotencia : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_t_EventoSalud_ID_EventoAgenda",
                table: "t_EventoSalud");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoSalud_ID_EventoAgenda_FechaOcurrenciaEventoAgenda",
                table: "t_EventoSalud",
                columns: new[] { "ID_EventoAgenda", "FechaOcurrenciaEventoAgenda" },
                unique: true,
                filter: "[ID_EventoAgenda] IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_t_EventoSalud_ID_EventoAgenda_FechaOcurrenciaEventoAgenda",
                table: "t_EventoSalud");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoSalud_ID_EventoAgenda",
                table: "t_EventoSalud",
                column: "ID_EventoAgenda");
        }
    }
}
