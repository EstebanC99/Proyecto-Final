using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class MigracionCodigoVerificacion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_CodigoVerificacionEmail");

            migrationBuilder.CreateTable(
                name: "t_CodigoVerificacion",
                columns: table => new
                {
                    ID_CodigoVerificacion = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Usuario = table.Column<int>(type: "int", nullable: false),
                    Tipo = table.Column<int>(type: "int", nullable: false),
                    CodigoHash = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Expiracion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Consumido = table.Column<bool>(type: "bit", nullable: false),
                    IntentosFallidos = table.Column<int>(type: "int", nullable: false),
                    FechaCreacion = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_CodigoVerificacion", x => x.ID_CodigoVerificacion);
                    table.ForeignKey(
                        name: "FK_t_CodigoVerificacion_t_Usuario_ID_Usuario",
                        column: x => x.ID_Usuario,
                        principalTable: "t_Usuario",
                        principalColumn: "ID_Usuario",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_CodigoVerificacion_ID_Usuario",
                table: "t_CodigoVerificacion",
                column: "ID_Usuario");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_CodigoVerificacion");

            migrationBuilder.CreateTable(
                name: "t_CodigoVerificacionEmail",
                columns: table => new
                {
                    ID_CodigoVerificacionEmail = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Usuario = table.Column<int>(type: "int", nullable: false),
                    CodigoHash = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Consumido = table.Column<bool>(type: "bit", nullable: false),
                    Expiracion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    FechaCreacion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IntentosFallidos = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_CodigoVerificacionEmail", x => x.ID_CodigoVerificacionEmail);
                    table.ForeignKey(
                        name: "FK_t_CodigoVerificacionEmail_t_Usuario_ID_Usuario",
                        column: x => x.ID_Usuario,
                        principalTable: "t_Usuario",
                        principalColumn: "ID_Usuario",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_CodigoVerificacionEmail_ID_Usuario",
                table: "t_CodigoVerificacionEmail",
                column: "ID_Usuario");
        }
    }
}
