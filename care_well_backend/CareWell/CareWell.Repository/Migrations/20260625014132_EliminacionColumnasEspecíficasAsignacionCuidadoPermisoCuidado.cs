using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class EliminacionColumnasEspecíficasAsignacionCuidadoPermisoCuidado : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_AsignacionCuidadoPermisoCuidado_t_AsignacionCuidado_ID_AsignacionCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado");

            migrationBuilder.DropForeignKey(
                name: "FK_t_AsignacionCuidadoPermisoCuidado_t_PermisoCuidado_ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado");

            migrationBuilder.DropIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_ID_AsignacionCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado");

            migrationBuilder.DropIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado");

            migrationBuilder.DropColumn(
                name: "ID_AsignacionCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado");

            migrationBuilder.DropColumn(
                name: "ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ID_AsignacionCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_ID_AsignacionCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "ID_AsignacionCuidado");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "ID_PermisoCuidado");

            migrationBuilder.AddForeignKey(
                name: "FK_t_AsignacionCuidadoPermisoCuidado_t_AsignacionCuidado_ID_AsignacionCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "ID_AsignacionCuidado",
                principalTable: "t_AsignacionCuidado",
                principalColumn: "ID_AsignacionCuidado");

            migrationBuilder.AddForeignKey(
                name: "FK_t_AsignacionCuidadoPermisoCuidado_t_PermisoCuidado_ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "ID_PermisoCuidado",
                principalTable: "t_PermisoCuidado",
                principalColumn: "ID_PermisoCuidado",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
