-- 1. Login a nivel servidor
CREATE LOGIN CareWellAdmin
    WITH PASSWORD = 'Pass@word1!!',
    CHECK_POLICY = ON;
GO
-- 2. Permisos para crear Base de Datos
ALTER SERVER ROLE dbcreator ADD MEMBER CareWellAdmin;
GO

-- 3. Creacion de la Base de Datos
CREATE DATABASE CareWell;
GO

-- 4. User dentro de la base CareWell, mapeado al login
USE CareWell;
GO
CREATE USER CareWellAdmin FOR LOGIN CareWellAdmin;
GO

-- 5. Permisos sobre esa base
ALTER ROLE db_owner ADD MEMBER CareWellAdmin;
GO