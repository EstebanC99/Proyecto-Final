using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class PersistenciaResumenDiario : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "t_ResumenDiario",
                columns: table => new
                {
                    ID_ResumenDiario = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    FechaHoraGeneracion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Contenido = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_ResumenDiario", x => x.ID_ResumenDiario);
                    table.ForeignKey(
                        name: "FK_t_ResumenDiario_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_ResumenDiario_ID_Persona",
                table: "t_ResumenDiario",
                column: "ID_Persona",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_ResumenDiario");
        }
    }
}
