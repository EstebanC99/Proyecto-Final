using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class CreacionDbParaNotebook : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_PersonaEstadoAnimo_t_EventoSalud_ID_EventoSalud",
                table: "t_PersonaEstadoAnimo");

            migrationBuilder.DropIndex(
                name: "IX_t_PersonaEstadoAnimo_ID_EventoSalud",
                table: "t_PersonaEstadoAnimo");

            migrationBuilder.DropColumn(
                name: "ID_EventoSalud",
                table: "t_PersonaEstadoAnimo");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ID_EventoSalud",
                table: "t_PersonaEstadoAnimo",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_t_PersonaEstadoAnimo_ID_EventoSalud",
                table: "t_PersonaEstadoAnimo",
                column: "ID_EventoSalud");

            migrationBuilder.AddForeignKey(
                name: "FK_t_PersonaEstadoAnimo_t_EventoSalud_ID_EventoSalud",
                table: "t_PersonaEstadoAnimo",
                column: "ID_EventoSalud",
                principalTable: "t_EventoSalud",
                principalColumn: "ID_EventoSalud",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
