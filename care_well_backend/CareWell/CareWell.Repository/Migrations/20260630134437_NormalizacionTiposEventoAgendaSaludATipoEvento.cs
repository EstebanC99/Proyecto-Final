using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class NormalizacionTiposEventoAgendaSaludATipoEvento : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_EventoAgenda_t_TipoEventoAgenda_ID_TipoEventoAgenda",
                table: "t_EventoAgenda");

            migrationBuilder.DropForeignKey(
                name: "FK_t_EventoSalud_t_TipoEventoSalud_ID_TipoEventoSalud",
                table: "t_EventoSalud");

            migrationBuilder.DropTable(
                name: "t_TipoEventoAgenda");

            migrationBuilder.DropTable(
                name: "t_TipoEventoSalud");

            migrationBuilder.RenameColumn(
                name: "ID_TipoEventoSalud",
                table: "t_EventoSalud",
                newName: "ID_TipoEvento");

            migrationBuilder.RenameIndex(
                name: "IX_t_EventoSalud_ID_TipoEventoSalud",
                table: "t_EventoSalud",
                newName: "IX_t_EventoSalud_ID_TipoEvento");

            migrationBuilder.RenameColumn(
                name: "ID_TipoEventoAgenda",
                table: "t_EventoAgenda",
                newName: "ID_TipoEvento");

            migrationBuilder.RenameIndex(
                name: "IX_t_EventoAgenda_ID_TipoEventoAgenda",
                table: "t_EventoAgenda",
                newName: "IX_t_EventoAgenda_ID_TipoEvento");

            migrationBuilder.CreateTable(
                name: "t_TipoEvento",
                columns: table => new
                {
                    ID_TipoEvento = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Agendable = table.Column<bool>(type: "bit", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_TipoEvento", x => x.ID_TipoEvento);
                });

            migrationBuilder.AddForeignKey(
                name: "FK_t_EventoAgenda_t_TipoEvento_ID_TipoEvento",
                table: "t_EventoAgenda",
                column: "ID_TipoEvento",
                principalTable: "t_TipoEvento",
                principalColumn: "ID_TipoEvento",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_t_EventoSalud_t_TipoEvento_ID_TipoEvento",
                table: "t_EventoSalud",
                column: "ID_TipoEvento",
                principalTable: "t_TipoEvento",
                principalColumn: "ID_TipoEvento",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_EventoAgenda_t_TipoEvento_ID_TipoEvento",
                table: "t_EventoAgenda");

            migrationBuilder.DropForeignKey(
                name: "FK_t_EventoSalud_t_TipoEvento_ID_TipoEvento",
                table: "t_EventoSalud");

            migrationBuilder.DropTable(
                name: "t_TipoEvento");

            migrationBuilder.RenameColumn(
                name: "ID_TipoEvento",
                table: "t_EventoSalud",
                newName: "ID_TipoEventoSalud");

            migrationBuilder.RenameIndex(
                name: "IX_t_EventoSalud_ID_TipoEvento",
                table: "t_EventoSalud",
                newName: "IX_t_EventoSalud_ID_TipoEventoSalud");

            migrationBuilder.RenameColumn(
                name: "ID_TipoEvento",
                table: "t_EventoAgenda",
                newName: "ID_TipoEventoAgenda");

            migrationBuilder.RenameIndex(
                name: "IX_t_EventoAgenda_ID_TipoEvento",
                table: "t_EventoAgenda",
                newName: "IX_t_EventoAgenda_ID_TipoEventoAgenda");

            migrationBuilder.CreateTable(
                name: "t_TipoEventoAgenda",
                columns: table => new
                {
                    ID_TipoEventoAgenda = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_TipoEventoAgenda", x => x.ID_TipoEventoAgenda);
                });

            migrationBuilder.CreateTable(
                name: "t_TipoEventoSalud",
                columns: table => new
                {
                    ID_TipoEventoSalud = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_TipoEventoSalud", x => x.ID_TipoEventoSalud);
                });

            migrationBuilder.AddForeignKey(
                name: "FK_t_EventoAgenda_t_TipoEventoAgenda_ID_TipoEventoAgenda",
                table: "t_EventoAgenda",
                column: "ID_TipoEventoAgenda",
                principalTable: "t_TipoEventoAgenda",
                principalColumn: "ID_TipoEventoAgenda",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_t_EventoSalud_t_TipoEventoSalud_ID_TipoEventoSalud",
                table: "t_EventoSalud",
                column: "ID_TipoEventoSalud",
                principalTable: "t_TipoEventoSalud",
                principalColumn: "ID_TipoEventoSalud",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
