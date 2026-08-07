--------------------------------------------------------------------------
----                     SCRIPTS POST DEPLOYMENT                      ----
--------------------------------------------------------------------------


------------------------ TipoEvento --------------------------------
SET IDENTITY_INSERT t_TipoEvento ON;
MERGE t_TipoEvento AS Destino
USING (VALUES
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
    (13, 'Otro', 1)
) AS Origen (ID_TipoEvento, Descripcion, Agendable)
ON Destino.ID_TipoEvento = Origen.ID_TipoEvento
WHEN NOT MATCHED THEN
    INSERT (ID_TipoEvento, Descripcion, Agendable)
    VALUES (Origen.ID_TipoEvento, Origen.Descripcion, Origen.Agendable);
SET IDENTITY_INSERT t_TipoEvento OFF;
GO
--------------------------------------------------------------------------

------------------------ EstadoUsuario -----------------------------------
SET IDENTITY_INSERT t_EstadoUsuario ON;
MERGE t_EstadoUsuario AS Destino
USING (VALUES
    (1, 'Activo'),
    (2, 'Suspendido'),
    (3, 'Eliminado'),
    (4, 'Pendiente de validacion de email')
) AS Origen (ID_EstadoUsuario, Descripcion)
ON Destino.ID_EstadoUsuario = Origen.ID_EstadoUsuario
WHEN NOT MATCHED THEN
    INSERT (ID_EstadoUsuario, Descripcion)
    VALUES (Origen.ID_EstadoUsuario, Origen.Descripcion);
SET IDENTITY_INSERT t_EstadoUsuario OFF;
GO
--------------------------------------------------------------------------

------------------------ EstadoAsignacionCuidado -------------------------
SET IDENTITY_INSERT t_EstadoAsignacionCuidado ON;
MERGE t_EstadoAsignacionCuidado AS Destino
USING (VALUES
    (1, 'Activa'),
    (2, 'Inactiva'),
    (3, 'Pendiente')
) AS Origen (ID_EstadoAsignacionCuidado, Descripcion)
ON Destino.ID_EstadoAsignacionCuidado = Origen.ID_EstadoAsignacionCuidado
WHEN NOT MATCHED THEN
    INSERT (ID_EstadoAsignacionCuidado, Descripcion)
    VALUES (Origen.ID_EstadoAsignacionCuidado, Origen.Descripcion);
SET IDENTITY_INSERT t_EstadoAsignacionCuidado OFF;
GO
--------------------------------------------------------------------------

------------------------ PermisoCuidado ----------------------------------
SET IDENTITY_INSERT t_PermisoCuidado ON;
MERGE t_PermisoCuidado AS Destino
USING (VALUES
    (1, 'Ver Ficha de Salud'),
    (2, 'Editar Ficha de Salud'),
    (3, 'Gestionar Agenda'),
    (4, 'Registrar Eventos de Salud'),
    (5, 'Registrar Hábitos'),
    (6, 'Activar Emergencia'),
    (7, 'Administrar Equipo')
) AS Origen (ID_PermisoCuidado, Descripcion)
ON Destino.ID_PermisoCuidado = Origen.ID_PermisoCuidado
WHEN NOT MATCHED THEN
    INSERT (ID_PermisoCuidado, Descripcion)
    VALUES (Origen.ID_PermisoCuidado, Origen.Descripcion);
SET IDENTITY_INSERT t_PermisoCuidado OFF;
GO
--------------------------------------------------------------------------

-------------------------- RolCuidado ------------------------------------
SET IDENTITY_INSERT t_RolCuidado ON;
MERGE t_RolCuidado AS Destino
USING (VALUES
    (1, 'Responsable'),
    (2, 'Cuidador')
) AS Origen (ID_RolCuidado, Descripcion)
ON Destino.ID_RolCuidado = Origen.ID_RolCuidado
WHEN NOT MATCHED THEN
    INSERT (ID_RolCuidado, Descripcion)
    VALUES (Origen.ID_RolCuidado, Origen.Descripcion);
SET IDENTITY_INSERT t_RolCuidado OFF;
GO
--------------------------------------------------------------------------

------------------------ EstadoAnimo -------------------------------------
SET IDENTITY_INSERT t_EstadoAnimo ON;
MERGE t_EstadoAnimo AS Destino
USING (VALUES
    (1, 'Muy Bien'),
    (2, 'Bien'),
    (3, 'Regular'),
    (4, 'Mal'),
    (5, 'Muy Mal')
) AS Origen (ID_EstadoAnimo, Descripcion)
ON Destino.ID_EstadoAnimo = Origen.ID_EstadoAnimo
WHEN NOT MATCHED THEN
    INSERT (ID_EstadoAnimo, Descripcion)
    VALUES (Origen.ID_EstadoAnimo, Origen.Descripcion);
SET IDENTITY_INSERT t_EstadoAnimo OFF;
GO
--------------------------------------------------------------------------

------------------------ TipoHabitoVida ----------------------------------
SET IDENTITY_INSERT t_TipoHabitoVida ON;
MERGE t_TipoHabitoVida AS Destino
USING (VALUES
    (1, 'Actividad Física'),
    (2, 'Alimentación'),
    (3, 'Sueño'),
    (4, 'Hidratación'),
    (5, 'Otro')
) AS Origen (ID_TipoHabitoVida, Descripcion)
ON Destino.ID_TipoHabitoVida = Origen.ID_TipoHabitoVida
WHEN NOT MATCHED THEN
    INSERT (ID_TipoHabitoVida, Descripcion)
    VALUES (Origen.ID_TipoHabitoVida, Origen.Descripcion);
SET IDENTITY_INSERT t_TipoHabitoVida OFF;
GO
--------------------------------------------------------------------------