using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CareWell.Repository.Migrations
{
    /// <inheritdoc />
    public partial class InitialRecreation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "t_EstadoAnimo",
                columns: table => new
                {
                    ID_EstadoAnimo = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_EstadoAnimo", x => x.ID_EstadoAnimo);
                });

            migrationBuilder.CreateTable(
                name: "t_EstadoAsignacionCuidado",
                columns: table => new
                {
                    ID_EstadoAsignacionCuidado = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_EstadoAsignacionCuidado", x => x.ID_EstadoAsignacionCuidado);
                });

            migrationBuilder.CreateTable(
                name: "t_EstadoUsuario",
                columns: table => new
                {
                    ID_EstadoUsuario = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_EstadoUsuario", x => x.ID_EstadoUsuario);
                });

            migrationBuilder.CreateTable(
                name: "t_PermisoCuidado",
                columns: table => new
                {
                    ID_PermisoCuidado = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_PermisoCuidado", x => x.ID_PermisoCuidado);
                });

            migrationBuilder.CreateTable(
                name: "t_Persona",
                columns: table => new
                {
                    ID_Persona = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nombre = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Apellido = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Documento = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    FechaNacimiento = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    Telefono = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    ImagenPath = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_Persona", x => x.ID_Persona);
                });

            migrationBuilder.CreateTable(
                name: "t_RolCuidado",
                columns: table => new
                {
                    ID_RolCuidado = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_RolCuidado", x => x.ID_RolCuidado);
                });

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

            migrationBuilder.CreateTable(
                name: "t_TipoHabitoVida",
                columns: table => new
                {
                    ID_TipoHabitoVida = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Descripcion = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_TipoHabitoVida", x => x.ID_TipoHabitoVida);
                });

            migrationBuilder.CreateTable(
                name: "t_Emergencia",
                columns: table => new
                {
                    ID_Emergencia = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    FechaHora = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Atendida = table.Column<bool>(type: "bit", nullable: false),
                    Descripcion = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_Emergencia", x => x.ID_Emergencia);
                    table.ForeignKey(
                        name: "FK_t_Emergencia_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_FichaSalud",
                columns: table => new
                {
                    ID_FichaSalud = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    Antecedentes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Estudios = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_FichaSalud", x => x.ID_FichaSalud);
                    table.ForeignKey(
                        name: "FK_t_FichaSalud_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_RecomendacionMedica",
                columns: table => new
                {
                    ID_RecomendacionMedica = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    Descripcion = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FechaHora = table.Column<DateTime>(type: "datetime2", nullable: false),
                    NombreProfesional = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_RecomendacionMedica", x => x.ID_RecomendacionMedica);
                    table.ForeignKey(
                        name: "FK_t_RecomendacionMedica_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_Usuario",
                columns: table => new
                {
                    ID_Usuario = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    NombreUsuario = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ContrasenaHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ID_Estado = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_Usuario", x => x.ID_Usuario);
                    table.ForeignKey(
                        name: "FK_t_Usuario_t_EstadoUsuario_ID_Estado",
                        column: x => x.ID_Estado,
                        principalTable: "t_EstadoUsuario",
                        principalColumn: "ID_EstadoUsuario",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_Usuario_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_AsignacionCuidado",
                columns: table => new
                {
                    ID_AsignacionCuidado = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona_Cuidada = table.Column<int>(type: "int", nullable: false),
                    ID_Persona_Colaborador = table.Column<int>(type: "int", nullable: false),
                    ID_RolCuidado = table.Column<int>(type: "int", nullable: false),
                    ID_EstadoAsignacionCuidado = table.Column<int>(type: "int", nullable: false),
                    FechaAlta = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_AsignacionCuidado", x => x.ID_AsignacionCuidado);
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidado_t_EstadoAsignacionCuidado_ID_EstadoAsignacionCuidado",
                        column: x => x.ID_EstadoAsignacionCuidado,
                        principalTable: "t_EstadoAsignacionCuidado",
                        principalColumn: "ID_EstadoAsignacionCuidado",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidado_t_Persona_ID_Persona_Colaborador",
                        column: x => x.ID_Persona_Colaborador,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidado_t_Persona_ID_Persona_Cuidada",
                        column: x => x.ID_Persona_Cuidada,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_AsignacionCuidado_t_RolCuidado_ID_RolCuidado",
                        column: x => x.ID_RolCuidado,
                        principalTable: "t_RolCuidado",
                        principalColumn: "ID_RolCuidado",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_EventoSalud",
                columns: table => new
                {
                    ID_EventoSalud = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    ID_TipoEventoSalud = table.Column<int>(type: "int", nullable: false),
                    FechaHora = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Descripcion = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_EventoSalud", x => x.ID_EventoSalud);
                    table.ForeignKey(
                        name: "FK_t_EventoSalud_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_EventoSalud_t_TipoEventoSalud_ID_TipoEventoSalud",
                        column: x => x.ID_TipoEventoSalud,
                        principalTable: "t_TipoEventoSalud",
                        principalColumn: "ID_TipoEventoSalud",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_HabitoVida",
                columns: table => new
                {
                    ID_HabitoVida = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    ID_TipoHabitoVida = table.Column<int>(type: "int", nullable: false),
                    Descripcion = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_HabitoVida", x => x.ID_HabitoVida);
                    table.ForeignKey(
                        name: "FK_t_HabitoVida_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_HabitoVida_t_TipoHabitoVida_ID_TipoHabitoVida",
                        column: x => x.ID_TipoHabitoVida,
                        principalTable: "t_TipoHabitoVida",
                        principalColumn: "ID_TipoHabitoVida",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_EventoAgenda",
                columns: table => new
                {
                    ID_EventoAgenda = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    ID_Usuario = table.Column<int>(type: "int", nullable: false),
                    Titulo = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Descripcion = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    ID_TipoEventoAgenda = table.Column<int>(type: "int", nullable: false),
                    FechaHoraInicio = table.Column<DateTime>(type: "datetime2", nullable: false),
                    FechaHoraFin = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_EventoAgenda", x => x.ID_EventoAgenda);
                    table.ForeignKey(
                        name: "FK_t_EventoAgenda_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_EventoAgenda_t_TipoEventoAgenda_ID_TipoEventoAgenda",
                        column: x => x.ID_TipoEventoAgenda,
                        principalTable: "t_TipoEventoAgenda",
                        principalColumn: "ID_TipoEventoAgenda",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_t_EventoAgenda_t_Usuario_ID_Usuario",
                        column: x => x.ID_Usuario,
                        principalTable: "t_Usuario",
                        principalColumn: "ID_Usuario",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_RefreshToken",
                columns: table => new
                {
                    ID_RefreshToken = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Token = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ID_Usuario = table.Column<int>(type: "int", nullable: false),
                    Expiracion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Revocado = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_RefreshToken", x => x.ID_RefreshToken);
                    table.ForeignKey(
                        name: "FK_t_RefreshToken_t_Usuario_ID_Usuario",
                        column: x => x.ID_Usuario,
                        principalTable: "t_Usuario",
                        principalColumn: "ID_Usuario",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "t_AsignacionCuidadoPermisoCuidado",
                columns: table => new
                {
                    AsignacionCuidadoID = table.Column<int>(type: "int", nullable: false),
                    PermisosID = table.Column<int>(type: "int", nullable: false),
                    ID_AsignacionCuidado = table.Column<int>(type: "int", nullable: true),
                    ID_PermisoCuidado = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_AsignacionCuidadoPermisoCuidado", x => new { x.AsignacionCuidadoID, x.PermisosID });
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

            migrationBuilder.CreateTable(
                name: "t_NotaEventoSalud",
                columns: table => new
                {
                    ID_NotaEventoSalud = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    FechaHora = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Contenido = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ID_EventoSalud = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_NotaEventoSalud", x => x.ID_NotaEventoSalud);
                    table.ForeignKey(
                        name: "FK_t_NotaEventoSalud_t_EventoSalud_ID_EventoSalud",
                        column: x => x.ID_EventoSalud,
                        principalTable: "t_EventoSalud",
                        principalColumn: "ID_EventoSalud",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_t_NotaEventoSalud_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "t_PersonaEstadoAnimo",
                columns: table => new
                {
                    ID_PersonaEstadoAnimo = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_Persona = table.Column<int>(type: "int", nullable: false),
                    ID_EventoSalud = table.Column<int>(type: "int", nullable: true),
                    FechaHora = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ID_EstadoAnimo = table.Column<int>(type: "int", nullable: false),
                    Observaciones = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_PersonaEstadoAnimo", x => x.ID_PersonaEstadoAnimo);
                    table.ForeignKey(
                        name: "FK_t_PersonaEstadoAnimo_t_EstadoAnimo_ID_EstadoAnimo",
                        column: x => x.ID_EstadoAnimo,
                        principalTable: "t_EstadoAnimo",
                        principalColumn: "ID_EstadoAnimo",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_t_PersonaEstadoAnimo_t_EventoSalud_ID_EventoSalud",
                        column: x => x.ID_EventoSalud,
                        principalTable: "t_EventoSalud",
                        principalColumn: "ID_EventoSalud",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_t_PersonaEstadoAnimo_t_Persona_ID_Persona",
                        column: x => x.ID_Persona,
                        principalTable: "t_Persona",
                        principalColumn: "ID_Persona",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "t_EventoAgendaRecordatorio",
                columns: table => new
                {
                    ID_EventoAgendaRecordatorio = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ID_EventoAgenda = table.Column<int>(type: "int", nullable: false),
                    FechaHoraEnvio = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Enviado = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_t_EventoAgendaRecordatorio", x => x.ID_EventoAgendaRecordatorio);
                    table.ForeignKey(
                        name: "FK_t_EventoAgendaRecordatorio_t_EventoAgenda_ID_EventoAgenda",
                        column: x => x.ID_EventoAgenda,
                        principalTable: "t_EventoAgenda",
                        principalColumn: "ID_EventoAgenda",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidado_ID_EstadoAsignacionCuidado",
                table: "t_AsignacionCuidado",
                column: "ID_EstadoAsignacionCuidado");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidado_ID_Persona_Colaborador",
                table: "t_AsignacionCuidado",
                column: "ID_Persona_Colaborador");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidado_ID_Persona_Cuidada",
                table: "t_AsignacionCuidado",
                column: "ID_Persona_Cuidada");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidado_ID_RolCuidado",
                table: "t_AsignacionCuidado",
                column: "ID_RolCuidado");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_ID_AsignacionCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "ID_AsignacionCuidado");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_ID_PermisoCuidado",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "ID_PermisoCuidado");

            migrationBuilder.CreateIndex(
                name: "IX_t_AsignacionCuidadoPermisoCuidado_PermisosID",
                table: "t_AsignacionCuidadoPermisoCuidado",
                column: "PermisosID");

            migrationBuilder.CreateIndex(
                name: "IX_t_Emergencia_ID_Persona",
                table: "t_Emergencia",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoAgenda_ID_Persona",
                table: "t_EventoAgenda",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoAgenda_ID_TipoEventoAgenda",
                table: "t_EventoAgenda",
                column: "ID_TipoEventoAgenda");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoAgenda_ID_Usuario",
                table: "t_EventoAgenda",
                column: "ID_Usuario");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoAgendaRecordatorio_ID_EventoAgenda",
                table: "t_EventoAgendaRecordatorio",
                column: "ID_EventoAgenda");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoSalud_ID_Persona",
                table: "t_EventoSalud",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_EventoSalud_ID_TipoEventoSalud",
                table: "t_EventoSalud",
                column: "ID_TipoEventoSalud");

            migrationBuilder.CreateIndex(
                name: "IX_t_FichaSalud_ID_Persona",
                table: "t_FichaSalud",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_HabitoVida_ID_Persona",
                table: "t_HabitoVida",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_HabitoVida_ID_TipoHabitoVida",
                table: "t_HabitoVida",
                column: "ID_TipoHabitoVida");

            migrationBuilder.CreateIndex(
                name: "IX_t_NotaEventoSalud_ID_EventoSalud",
                table: "t_NotaEventoSalud",
                column: "ID_EventoSalud");

            migrationBuilder.CreateIndex(
                name: "IX_t_NotaEventoSalud_ID_Persona",
                table: "t_NotaEventoSalud",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_PersonaEstadoAnimo_ID_EstadoAnimo",
                table: "t_PersonaEstadoAnimo",
                column: "ID_EstadoAnimo");

            migrationBuilder.CreateIndex(
                name: "IX_t_PersonaEstadoAnimo_ID_EventoSalud",
                table: "t_PersonaEstadoAnimo",
                column: "ID_EventoSalud");

            migrationBuilder.CreateIndex(
                name: "IX_t_PersonaEstadoAnimo_ID_Persona",
                table: "t_PersonaEstadoAnimo",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_RecomendacionMedica_ID_Persona",
                table: "t_RecomendacionMedica",
                column: "ID_Persona");

            migrationBuilder.CreateIndex(
                name: "IX_t_RefreshToken_ID_Usuario",
                table: "t_RefreshToken",
                column: "ID_Usuario");

            migrationBuilder.CreateIndex(
                name: "IX_t_Usuario_ID_Estado",
                table: "t_Usuario",
                column: "ID_Estado");

            migrationBuilder.CreateIndex(
                name: "IX_t_Usuario_ID_Persona",
                table: "t_Usuario",
                column: "ID_Persona");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "t_AsignacionCuidadoPermisoCuidado");

            migrationBuilder.DropTable(
                name: "t_Emergencia");

            migrationBuilder.DropTable(
                name: "t_EventoAgendaRecordatorio");

            migrationBuilder.DropTable(
                name: "t_FichaSalud");

            migrationBuilder.DropTable(
                name: "t_HabitoVida");

            migrationBuilder.DropTable(
                name: "t_NotaEventoSalud");

            migrationBuilder.DropTable(
                name: "t_PersonaEstadoAnimo");

            migrationBuilder.DropTable(
                name: "t_RecomendacionMedica");

            migrationBuilder.DropTable(
                name: "t_RefreshToken");

            migrationBuilder.DropTable(
                name: "t_AsignacionCuidado");

            migrationBuilder.DropTable(
                name: "t_PermisoCuidado");

            migrationBuilder.DropTable(
                name: "t_EventoAgenda");

            migrationBuilder.DropTable(
                name: "t_TipoHabitoVida");

            migrationBuilder.DropTable(
                name: "t_EstadoAnimo");

            migrationBuilder.DropTable(
                name: "t_EventoSalud");

            migrationBuilder.DropTable(
                name: "t_EstadoAsignacionCuidado");

            migrationBuilder.DropTable(
                name: "t_RolCuidado");

            migrationBuilder.DropTable(
                name: "t_TipoEventoAgenda");

            migrationBuilder.DropTable(
                name: "t_Usuario");

            migrationBuilder.DropTable(
                name: "t_TipoEventoSalud");

            migrationBuilder.DropTable(
                name: "t_EstadoUsuario");

            migrationBuilder.DropTable(
                name: "t_Persona");
        }
    }
}
