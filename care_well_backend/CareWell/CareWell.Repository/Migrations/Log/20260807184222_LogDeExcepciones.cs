using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations.Log
{
    /// <inheritdoc />
    public partial class LogDeExcepciones : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "t_LogExcepcion",
                columns: table => new
                {
                    ID_LogExcepcion = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Tipo = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Controlada = table.Column<bool>(type: "bit", nullable: false),
                    Mensaje = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    StackTrace = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Ruta = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Verbo = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    TraceIdentifier = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    UsuarioID = table.Column<int>(type: "int", nullable: true),
                    FechaHora = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_LogExcepcion", x => x.ID_LogExcepcion);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_LogExcepcion_Controlada_FechaHora",
                table: "t_LogExcepcion",
                columns: new[] { "Controlada", "FechaHora" });

            migrationBuilder.CreateIndex(
                name: "IX_t_LogExcepcion_FechaHora",
                table: "t_LogExcepcion",
                column: "FechaHora");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_LogExcepcion");
        }
    }
}
