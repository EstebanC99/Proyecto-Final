--------------------------------------------------------------------------
----					SCRIPTS POST DEPLOYMENT						  ----
--------------------------------------------------------------------------


------------------------ TipoEventoAgenda --------------------------------
SET IDENTITY_INSERT t_TipoEventoAgenda ON;
INSERT INTO t_TipoEventoAgenda (ID_TipoEventoAgenda, Descripcion) VALUES
(1, 'Cita Médica'),
(2, 'Medicación'),
(3, 'Rehabilitación'),
(4, 'Control'),
(5, 'Otro');
SET IDENTITY_INSERT t_TipoEventoAgenda OFF;
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

------------------------ TipoEventoSalud ---------------------------------
SET IDENTITY_INSERT t_TipoEventoSalud ON;
INSERT INTO t_TipoEventoSalud (ID_TipoEventoSalud, Descripcion) VALUES
(1, 'Cita Médica'),
(2, 'Hospitalización'),
(3, 'Medicación'),
(4, 'Cirugía'),
(5, 'Tratamiento'),
(6, 'Bienestar'),
(7, 'Síntoma'),
(8, 'Diagnóstico'),
(9, 'Vacuna'),
(10, 'Otro');
SET IDENTITY_INSERT t_TipoEventoSalud OFF;
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