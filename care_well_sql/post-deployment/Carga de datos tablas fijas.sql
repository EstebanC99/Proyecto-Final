--------------------------------------------------------------------------
----					SCRIPTS POST DEPLOYMENT						  ----
--------------------------------------------------------------------------


------------------------ TipoEvento --------------------------------
SET IDENTITY_INSERT t_TipoEvento ON;
INSERT INTO t_TipoEvento (ID_TipoEvento, Descripcion, Agendable) VALUES
(1, 'Cita Médica', 1),
(2, 'Medicación', 1),
(3, 'Rehabilitación', 1),
(4, 'Control', 1),
(5, 'Hospitalizacion', 0),
(6, 'Cirugia', 1),
(7, 'Tratamiento', 1),
(8, 'Bienestar', 0),
(9, 'Síntoma', 0),
(10, 'Diagnóstico', 0),
(11, 'Vacuna', 1),
(12, 'Actividad Física', 1),
(13, 'Otro', 1);
SET IDENTITY_INSERT t_TipoEvento OFF;
GO
--------------------------------------------------------------------------

------------------------ EstadoUsuario -----------------------------------
SET IDENTITY_INSERT t_EstadoUsuario ON;
INSERT INTO t_EstadoUsuario (ID_EstadoUsuario, Descripcion) VALUES
(1, 'Activo'),
(2, 'Suspendido'),
(3, 'Eliminado');
SET IDENTITY_INSERT t_EstadoUsuario OFF;
GO
--------------------------------------------------------------------------

------------------------ EstadoAsignacionCuidado -------------------------
SET IDENTITY_INSERT t_EstadoAsignacionCuidado ON;
INSERT INTO t_EstadoAsignacionCuidado (ID_EstadoAsignacionCuidado, Descripcion) VALUES
(1, 'Activa'),
(2, 'Inactiva'),
(3, 'Pendiente');
SET IDENTITY_INSERT t_EstadoAsignacionCuidado OFF;
GO
--------------------------------------------------------------------------

------------------------ PermisoCuidado ----------------------------------
SET IDENTITY_INSERT t_PermisoCuidado ON;
INSERT INTO t_PermisoCuidado (ID_PermisoCuidado, Descripcion) VALUES
(1, 'Ver Ficha de Salud'),
(2, 'Editar Ficha de Salud'),
(3, 'Gestionar Agenda'),
(4, 'Registrar Eventos de Salud'),
(5, 'Registrar Hábitos'),
(6, 'Activar Emergencia'),
(7, 'Administrar Equipo');
SET IDENTITY_INSERT t_PermisoCuidado OFF;
GO
--------------------------------------------------------------------------

-------------------------- RolCuidado ------------------------------------
SET IDENTITY_INSERT t_RolCuidado ON;
INSERT INTO t_RolCuidado (ID_RolCuidado, Descripcion) VALUES
(1, 'Responsable'),
(2, 'Cuidador');
SET IDENTITY_INSERT t_RolCuidado OFF;
GO
--------------------------------------------------------------------------

------------------------ EstadoAnimo -------------------------------------
SET IDENTITY_INSERT t_EstadoAnimo ON;
INSERT INTO t_EstadoAnimo (ID_EstadoAnimo, Descripcion) VALUES
(1, 'Muy Bien'),
(2, 'Bien'),
(3, 'Regular'),
(4, 'Mal'),
(5, 'Muy Mal');
SET IDENTITY_INSERT t_EstadoAnimo OFF;
GO
--------------------------------------------------------------------------

------------------------ TipoHabitoVida ----------------------------------
SET IDENTITY_INSERT t_TipoHabitoVida ON;
INSERT INTO t_TipoHabitoVida (ID_TipoHabitoVida, Descripcion) VALUES
(1, 'Actividad Física'),
(2, 'Alimentación'),
(3, 'Sueño'),
(4, 'Hidratación'),
(5, 'Otro');
SET IDENTITY_INSERT t_TipoHabitoVida OFF;
GO
--------------------------------------------------------------------------