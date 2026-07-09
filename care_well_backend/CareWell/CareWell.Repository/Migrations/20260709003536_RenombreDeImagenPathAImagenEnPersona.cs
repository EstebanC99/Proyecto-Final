using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class RenombreDeImagenPathAImagenEnPersona : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImagenPath",
                table: "t_Persona");

            migrationBuilder.AddColumn<string>(
                name: "Imagen",
                table: "t_Persona",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Imagen",
                table: "t_Persona");

            migrationBuilder.AddColumn<string>(
                name: "ImagenPath",
                table: "t_Persona",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);
        }
    }
}
