using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations.Log
{
    /// <inheritdoc />
    public partial class AgregarLogServicioExterno : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "t_LogServicioExterno",
                columns: table => new
                {
                    ID_LogServicioExterno = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NombreServicioExterno = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Request = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Response = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FechaHora = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_LogServicioExterno", x => x.ID_LogServicioExterno);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_LogServicioExterno_FechaHora",
                table: "t_LogServicioExterno",
                column: "FechaHora");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_LogServicioExterno");
        }
    }
}
