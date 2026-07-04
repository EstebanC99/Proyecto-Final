using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class AgregadoDeHabitoVidaRealizacio : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Activo",
                table: "t_HabitoVida",
                type: "bit",
                nullable: false,
                defaultValue: true);

            migrationBuilder.CreateTable(
                name: "t_HabitoVidaRealizacion",
                columns: table => new
                {
                    ID_HabitoVidaRealizacion = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_HabitoVida = table.Column<int>(type: "int", nullable: false),
                    FechaHoraRealizacion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Comentarios = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_HabitoVidaRealizacion", x => x.ID_HabitoVidaRealizacion);
                    table.ForeignKey(
                        name: "FK_t_HabitoVidaRealizacion_t_HabitoVida_ID_HabitoVida",
                        column: x => x.ID_HabitoVida,
                        principalTable: "t_HabitoVida",
                        principalColumn: "ID_HabitoVida",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_HabitoVidaRealizacion_ID_HabitoVida",
                table: "t_HabitoVidaRealizacion",
                column: "ID_HabitoVida");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_HabitoVidaRealizacion");

            migrationBuilder.DropColumn(
                name: "Activo",
                table: "t_HabitoVida");
        }
    }
}
