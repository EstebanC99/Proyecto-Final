using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class CambiosEnModeloFichaSalud : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Estudios",
                table: "t_FichaSalud",
                newName: "Observaciones");

            migrationBuilder.RenameColumn(
                name: "Antecedentes",
                table: "t_FichaSalud",
                newName: "ObraSocial");

            migrationBuilder.AddColumn<string>(
                name: "FactorSanguineo",
                table: "t_FichaSalud",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "t_FichaSaludAlergia",
                columns: table => new
                {
                    ID_FichaSaludAlergia = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_FichaSalud = table.Column<int>(type: "int", nullable: false),
                    Nombre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Reaccion = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Medicamento = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_FichaSaludAlergia", x => x.ID_FichaSaludAlergia);
                    table.ForeignKey(
                        name: "FK_t_FichaSaludAlergia_t_FichaSalud_ID_FichaSalud",
                        column: x => x.ID_FichaSalud,
                        principalTable: "t_FichaSalud",
                        principalColumn: "ID_FichaSalud",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "t_FichaSaludAntecedente",
                columns: table => new
                {
                    ID_FichaSaludAntecedente = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_FichaSalud = table.Column<int>(type: "int", nullable: false),
                    Nombre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Descripcion = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    VinculoFamiliar = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_FichaSaludAntecedente", x => x.ID_FichaSaludAntecedente);
                    table.ForeignKey(
                        name: "FK_t_FichaSaludAntecedente_t_FichaSalud_ID_FichaSalud",
                        column: x => x.ID_FichaSalud,
                        principalTable: "t_FichaSalud",
                        principalColumn: "ID_FichaSalud",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "t_FichaSaludEnfermedad",
                columns: table => new
                {
                    ID_FichaSaludEnfermedad = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_FichaSalud = table.Column<int>(type: "int", nullable: false),
                    Nombre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Vigente = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Observacion = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_FichaSaludEnfermedad", x => x.ID_FichaSaludEnfermedad);
                    table.ForeignKey(
                        name: "FK_t_FichaSaludEnfermedad_t_FichaSalud_ID_FichaSalud",
                        column: x => x.ID_FichaSalud,
                        principalTable: "t_FichaSalud",
                        principalColumn: "ID_FichaSalud",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_FichaSaludAlergia_ID_FichaSalud",
                table: "t_FichaSaludAlergia",
                column: "ID_FichaSalud");

            migrationBuilder.CreateIndex(
                name: "IX_t_FichaSaludAntecedente_ID_FichaSalud",
                table: "t_FichaSaludAntecedente",
                column: "ID_FichaSalud");

            migrationBuilder.CreateIndex(
                name: "IX_t_FichaSaludEnfermedad_ID_FichaSalud",
                table: "t_FichaSaludEnfermedad",
                column: "ID_FichaSalud");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_FichaSaludAlergia");

            migrationBuilder.DropTable(
                name: "t_FichaSaludAntecedente");

            migrationBuilder.DropTable(
                name: "t_FichaSaludEnfermedad");

            migrationBuilder.DropColumn(
                name: "FactorSanguineo",
                table: "t_FichaSalud");

            migrationBuilder.RenameColumn(
                name: "Observaciones",
                table: "t_FichaSalud",
                newName: "Estudios");

            migrationBuilder.RenameColumn(
                name: "ObraSocial",
                table: "t_FichaSalud",
                newName: "Antecedentes");
        }
    }
}
