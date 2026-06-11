using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class ActualizacionDeRolCuidadoyPermisoCuidado : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_t_PermisoCuidado_t_RolCuidado_ID_RolCuidado",
                table: "t_PermisoCuidado");

            migrationBuilder.DropForeignKey(
                name: "FK_t_RolCuidado_t_TipoRolCuidado_ID_TipoRolCuidado",
                table: "t_RolCuidado");

            migrationBuilder.DropTable(
                name: "t_TipoRolCuidado");

            migrationBuilder.DropIndex(
                name: "IX_t_RolCuidado_ID_TipoRolCuidado",
                table: "t_RolCuidado");

            migrationBuilder.DropIndex(
                name: "IX_t_PermisoCuidado_ID_RolCuidado",
                table: "t_PermisoCuidado");

            migrationBuilder.DropColumn(
                name: "ID_TipoRolCuidado",
                table: "t_RolCuidado");

            migrationBuilder.DropColumn(
                name: "ID_RolCuidado",
                table: "t_PermisoCuidado");

            migrationBuilder.RenameColumn(
                name: "ID_Estado",
                table: "t_EstadoUsuario",
                newName: "ID_EstadoUsuario");

            migrationBuilder.AddColumn<string>(
                name: "Descripcion",
                table: "t_RolCuidado",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "t_AsignacionCuidadoPermisoCuidado",
                columns: table => new
                {
                    ID_AsignacionCuidado = table.Column<int>(type: "int", nullable: false),
                    ID_PermisoCuidado = table.Column<int>(type: "int", nullable: false),
                    AsignacionCuidadoID = table.Column<int>(type: "int", nullable: false),
                    PermisosID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_AsignacionCuidadoPermisoCuidado", x => new { x.ID_AsignacionCuidado, x.ID_PermisoCuidado });
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidadoPermisoCuidado_t_AsignacionCuidado_AsignacionCuidadoID",
                        column: x => x.AsignacionCuidadoID,
                        principalTable: "t_AsignacionCuidado",
                        principalColumn: "ID_AsignacionCuidado",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidadoPermisoCuidado_t_AsignacionCuidado_ID_AsignacionCuidado",
                        column: x => x.ID_AsignacionCuidado,
                        principalTable: "t_AsignacionCuidado",
                        principalColumn: "ID_AsignacionCuidado");
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidadoPermisoCuidado_t_PermisoCuidado_ID_PermisoCuidado",
                        column: x => x.ID_PermisoCuidado,
                        principalTable: "t_PermisoCuidado",
                        principalColumn: "ID_PermisoCuidado",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidadoPermisoCuidado_t_PermisoCuidado_PermisosID",
                        column: x => x.PermisosID,
                        principalTable: "t_PermisoCuidado",
                        principalColumn: "ID_PermisoCuidado",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_AsignacionCuidadoID",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "AsignacionCuidadoID");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "ID_PermisoCuidado");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_PermisosID",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "PermisosID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_AsignacionCuidadoPermisoCuidado");

            migrationBuilder.DropColumn(
                name: "Descripcion",
                table: "t_RolCuidado");

            migrationBuilder.RenameColumn(
                name: "ID_EstadoUsuario",
                table: "t_EstadoUsuario",
                newName: "ID_Estado");

            migrationBuilder.AddColumn<int>(
                name: "ID_TipoRolCuidado",
                table: "t_RolCuidado",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "ID_RolCuidado",
                table: "t_PermisoCuidado",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "t_TipoRolCuidado",
                columns: table => new
                {
                    ID_TipoRolCuidado = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_TipoRolCuidado", x => x.ID_TipoRolCuidado);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_RolCuidado_ID_TipoRolCuidado",
                table: "t_RolCuidado",
                column: "ID_TipoRolCuidado");

            migrationBuilder.CreateIndex(
                name: "IX_t_PermisoCuidado_ID_RolCuidado",
                table: "t_PermisoCuidado",
                column: "ID_RolCuidado");

            migrationBuilder.AddForeignKey(
                name: "FK_t_PermisoCuidado_t_RolCuidado_ID_RolCuidado",
                table: "t_PermisoCuidado",
                column: "ID_RolCuidado",
                principalTable: "t_RolCuidado",
                principalColumn: "ID_RolCuidado",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_t_RolCuidado_t_TipoRolCuidado_ID_TipoRolCuidado",
                table: "t_RolCuidado",
                column: "ID_TipoRolCuidado",
                principalTable: "t_TipoRolCuidado",
                principalColumn: "ID_TipoRolCuidado",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
