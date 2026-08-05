using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class DispositivoUsuarioParaNotificacionesPush : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_t_Emergencia_ID_Persona",
                table: "t_Emergencia");

            migrationBuilder.DropColumn(
                name: "Atendida",
                table: "t_Emergencia");

            migrationBuilder.AddColumn<int>(
                name: "ID_Persona_Activador",
                table: "t_Emergencia",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "t_DispositivoUsuario",
                columns: table => new
                {
                    ID_DispositivoUsuario = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Usuario = table.Column<int>(type: "int", nullable: false),
                    Token = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Plataforma = table.Column<int>(type: "int", nullable: false),
                    Activo = table.Column<bool>(type: "bit", nullable: false),
                    FechaAlta = table.Column<DateTime>(type: "datetime2", nullable: false),
                    FechaUltimoUso = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_DispositivoUsuario", x => x.ID_DispositivoUsuario);
                    table.ForeignKey(
                        name: "FK_t_DispositivoUsuario_t_Usuario_ID_Usuario",
                        column: x => x.ID_Usuario,
                        principalTable: "t_Usuario",
                        principalColumn: "ID_Usuario",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_Emergencia_ID_Persona_Activador",
                table: "t_Emergencia",
                column: "ID_Persona_Activador");

            migrationBuilder.CreateIndex(
                name: "IX_t_Emergencia_ID_Persona_FechaHora",
                table: "t_Emergencia",
                columns: new[] { "ID_Persona", "FechaHora" });

            migrationBuilder.CreateIndex(
                name: "IX_t_DispositivoUsuario_ID_Usuario_Activo",
                table: "t_DispositivoUsuario",
                columns: new[] { "ID_Usuario", "Activo" });

            migrationBuilder.CreateIndex(
                name: "IX_t_DispositivoUsuario_Token",
                table: "t_DispositivoUsuario",
                column: "Token",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_t_Emergencia_t_Persona_ID_Persona_Activador",
                table: "t_Emergencia",
                column: "ID_Persona_Activador",
                principalTable: "t_Persona",
                principalColumn: "ID_Persona",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_Emergencia_t_Persona_ID_Persona_Activador",
                table: "t_Emergencia");

            migrationBuilder.DropTable(
                name: "t_DispositivoUsuario");

            migrationBuilder.DropIndex(
                name: "IX_t_Emergencia_ID_Persona_Activador",
                table: "t_Emergencia");

            migrationBuilder.DropIndex(
                name: "IX_t_Emergencia_ID_Persona_FechaHora",
                table: "t_Emergencia");

            migrationBuilder.DropColumn(
                name: "ID_Persona_Activador",
                table: "t_Emergencia");

            migrationBuilder.AddColumn<bool>(
                name: "Atendida",
                table: "t_Emergencia",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateIndex(
                name: "IX_t_Emergencia_ID_Persona",
                table: "t_Emergencia",
                column: "ID_Persona");
        }
    }
}
