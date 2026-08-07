# Cómo desplegar una versión actualizada del backend

> **Destinatario:** quien haga el deploy (hoy, el desarrollador backend)
> **Prerrequisito:** el VPS ya está aprovisionado (SSH, SQL Server, .NET Runtime, Caddy,
> systemd) según `care_well_doc/Specs/deploy-vps-donweb.md`. Esta guía es solo para
> **actualizar una versión ya desplegada**, no para la puesta en marcha inicial.
> Comandos del día a día del servidor (logs, backups, túnel a SSMS): `administracion.md`.

Datos del servidor (no sensibles — están acá para no tener que buscarlos):

| Dato | Valor |
|---|---|
| Host | `api.estecarsoft.com.ar` (IP `66.97.43.117`) |
| Puerto SSH | `5323` (el 22 está cerrado) |
| Usuario admin | `esteban` (con `sudo`) |
| Usuario de la app | `carewell` (sin login, dueño de los archivos) |
| Servicio systemd | `carewell-api` |
| Carpeta de la app | `/var/www/carewell/api` |
| Config/secretos | `/etc/carewell/carewell.env` (no versionado, ver `carewell.env.example`) |
| Base de datos | SQL Server Express, `localhost`, base `CareWell` |
| DbContexts | `CareWellDbContext` (tabla de historial `__EFMigrationsHistory`) y `LogDbContext` (`__EFMigrationsHistory_Log`) — **misma base**, migraciones independientes |

## 0. Lo que hay que saber antes de tocar nada

Desde el commit `2527e7f` (logs de excepciones y de servicios externos) la solución tiene
**dos DbContext**, y eso cambia el paso de migraciones:

| DbContext | Migraciones | Tabla de historial | Tablas que administra |
|---|---|---|---|
| `CareWell.Repository.CareWellDbContext` | `CareWell.Repository/Migrations/` | `__EFMigrationsHistory` | todo el dominio (`t_Persona`, `t_Usuario`, ...) |
| `CareWell.Repository.LogDbContext` | `CareWell.Repository/Migrations/Log/` | `__EFMigrationsHistory_Log` | `t_LogExcepcion`, `t_LogServicioExterno` |

Ambos usan **la misma connection string** (`ConnectionStrings__CareWellDb`, ver `Program.cs`
líneas 66-69): viven en la misma base `CareWell`, pero EF Core los trata como dos líneas de
migración separadas. Consecuencias prácticas:

- `dotnet ef migrations bundle` **ya no funciona sin `--context`** (da
  `More than one DbContext was found`). Hay que generar **un bundle por contexto**, con
  nombres de archivo distintos para que no se pisen.
- En el VPS se corren **los dos bundles**, uno detrás del otro, contra la misma connection
  string.
- El bundle de `LogDbContext` toma la opción `MigrationsHistoryTable("__EFMigrationsHistory_Log")`
  del registro de `Program.cs`, así que escribe su historial en la tabla correcta sin flags
  extra. (Se verifica después de migrar, ver 5.5.)
- Las configuraciones de log están **excluidas** del contexto principal
  (`CareWellDbContext.OnModelCreating` filtra el namespace `CareWell.Repository.Config.Auditoria`).
  Si alguna vez generás una migración del contexto principal y aparece un `t_LogExcepcion` /
  `t_LogServicioExterno` adentro, **frená**: se rompió esa exclusión y esa migración va a
  chocar contra las tablas que ya creó `LogDbContext`.

Riesgo si te olvidás de aplicar las migraciones del log: la API **no se cae** (el registro de
logs traga sus propios errores, ver `RegistrarLogExcepcionBusinessService.Registrar`), pero
perdés todos los logs de excepciones y de llamadas a servicios externos, y `journalctl` se
llena de `No se pudo registrar el log de la excepción ...`.

## 1. Verificaciones previas

- [ ] ¿Hay migraciones nuevas del **contexto principal** desde el último deploy?
      `git log --oneline -- care_well_backend/CareWell/CareWell.Repository/Migrations/`
- [ ] ¿Hay migraciones nuevas del **contexto de logs**?
      `git log --oneline -- care_well_backend/CareWell/CareWell.Repository/Migrations/Log/`
- [ ] ¿Cambió el script de catálogos (`care_well_sql/post-deployment/Carga de datos tablas
      fijas.sql`)? Si agregaste **valores nuevos** a un catálogo, hay que volver a correrlo:
      usa `MERGE ... WHEN NOT MATCHED THEN INSERT`, así que es idempotente (correrlo de más
      no rompe nada). Ojo: **no actualiza ni borra filas existentes** — si cambiaste la
      descripción de un ID que ya está en producción, el script no la va a pisar; eso hay que
      hacerlo a mano con un `UPDATE`.
- [ ] ¿Cambió `carewell.env.example` (claves de configuración nuevas)? Si sí, hay que agregar
      esas claves a `/etc/carewell/carewell.env` en el VPS **antes** de arrancar la versión
      nueva.
- [ ] `dotnet build CareWell.slnx` y los tests (`dotnet test CareWell.slnx`) en verde localmente.
- [ ] Herramienta `dotnet-ef` al día (si avisa que la tool es más vieja que el runtime):
      `dotnet tool update --global dotnet-ef`

Opcional pero recomendado si hace rato que no deployás — comparar lo que hay aplicado en
producción contra lo que hay en el repo (desde el VPS, ver 5.1):

```bash
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C -Q \
  "SELECT TOP 5 MigrationId FROM __EFMigrationsHistory ORDER BY MigrationId DESC"
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C -Q \
  "SELECT MigrationId FROM __EFMigrationsHistory_Log ORDER BY MigrationId DESC"
```

La segunda consulta va a dar `Invalid object name '__EFMigrationsHistory_Log'` **la primera
vez** (todavía no se aplicó ninguna migración de logs) — es lo esperado, no es un error.

## 2. Publicar el backend (en tu PC)

Desde `care_well_backend/CareWell/`:

```powershell
dotnet publish CareWell.API -c Release -r linux-x64 --self-contained false -o .\publish
```

## 3. (Solo si hay migraciones nuevas) Generar los migration bundles

**Un bundle por DbContext.** Corré solo el que corresponda si únicamente cambió uno de los dos
(lo más común: solo el principal).

### 3.1 Contexto principal (dominio)

```powershell
dotnet ef migrations bundle `
  --project CareWell.Repository `
  --startup-project CareWell.API `
  --context CareWellDbContext `
  --self-contained -r linux-x64 `
  --force `
  -o .\efbundle-carewell
```

### 3.2 Contexto de logs

```powershell
dotnet ef migrations bundle `
  --project CareWell.Repository `
  --startup-project CareWell.API `
  --context LogDbContext `
  --self-contained -r linux-x64 `
  --force `
  -o .\efbundle-log
```

Notas:
- `--context` acepta el nombre corto (`CareWellDbContext`) o el completo
  (`CareWell.Repository.CareWellDbContext`). Si lo omitís, el comando falla porque hay dos.
- `--force` sobrescribe el bundle anterior si quedó de un deploy pasado.
- Los bundles son **self-contained para linux-x64** (~90 MB cada uno): no necesitan SDK ni
  runtime en el VPS y se pueden borrar después de usarlos.
- Los bundles quedan en `care_well_backend/CareWell/`. El `.gitignore` ignora `efbundle`
  (nombre exacto) — conviene ampliarlo a `care_well_backend/CareWell/efbundle*` para que
  tampoco se cuelen `efbundle-carewell` ni `efbundle-log`. Mientras tanto, **no los commitees**.

## 4. Transferir al VPS

```powershell
scp -P 5323 -r .\publish esteban@66.97.43.117:~/deploy-publish
# solo si generaste bundles nuevos en el paso 3 (copiá el/los que correspondan):
scp -P 5323 .\efbundle-carewell esteban@66.97.43.117:~/
scp -P 5323 .\efbundle-log      esteban@66.97.43.117:~/
# solo si cambió el script de catálogos:
scp -P 5323 "D:\Projects\Proyecto-Final\care_well_sql\post-deployment\Carga de datos tablas fijas.sql" esteban@66.97.43.117:~/catalogos.sql
```

> Si `~/deploy-publish` quedó de un deploy anterior, `scp -r` va a anidar la carpeta dentro
> (`~/deploy-publish/publish`). Borrala antes en el VPS: `rm -rf ~/deploy-publish`.

## 5. En el VPS: aplicar la actualización

Conectate (`ssh -p 5323 esteban@66.97.43.117`) y seguí este orden — **parar el servicio antes
de tocar los archivos, migrar antes de arrancar de nuevo**:

```bash
# 5.1 Parar el servicio
sudo systemctl stop carewell-api

# 5.2 Backup de la base antes de migrar (por si hay que volver atrás)
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -C -Q \
  "BACKUP DATABASE CareWell TO DISK = '/var/opt/mssql/data/CareWell_$(date +%Y%m%d_%H%M).bak'"
# (el .bak lo escribe el proceso de SQL Server, por eso no hace falta sudo)

# 5.3 Backup de los binarios actuales (rollback rápido, sin republicar)
sudo rm -rf /var/www/carewell/api.bak
sudo cp -r /var/www/carewell/api /var/www/carewell/api.bak

# 5.4 (solo si hay bundle nuevo) Aplicar migraciones — PRIMERO el dominio, DESPUÉS los logs
chmod +x ~/efbundle-carewell ~/efbundle-log 2>/dev/null

./efbundle-carewell --connection 'Server=127.0.0.1;Database=CareWell;User ID=CareWellAdmin;Password=TU_PASSWORD;TrustServerCertificate=True;Encrypt=True;'
./efbundle-log      --connection 'Server=127.0.0.1;Database=CareWell;User ID=CareWellAdmin;Password=TU_PASSWORD;TrustServerCertificate=True;Encrypt=True;'

# 5.5 (solo si corriste el bundle de logs) Verificar que el historial fue a la tabla correcta
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C -Q \
  "SELECT name FROM sys.tables WHERE name IN ('t_LogExcepcion','t_LogServicioExterno','__EFMigrationsHistory','__EFMigrationsHistory_Log')"
# Esperado: las 4 filas. Si las migraciones de log aparecieran en __EFMigrationsHistory
# (y no en la _Log), pará y revisá el registro del LogDbContext en Program.cs.

# 5.6 (solo si cambió) Recargar catálogos — MERGE idempotente, no hace nada si no cambió nada
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C -i ~/catalogos.sql
rm -f ~/catalogos.sql

# 5.7 Reemplazar los binarios (conserva /etc/carewell y /var/lib/carewell, están fuera de esta carpeta)
sudo rm -rf /var/www/carewell/api/*
sudo cp -r ~/deploy-publish/* /var/www/carewell/api/
sudo chown -R carewell:carewell /var/www/carewell/api
rm -rf ~/deploy-publish ~/efbundle-carewell ~/efbundle-log

# 5.8 Arrancar de nuevo
sudo systemctl start carewell-api
sudo systemctl status carewell-api --no-pager
```

> El orden importa: **migrar con el servicio parado**. Si migrás con la API corriendo, durante
> unos segundos hay binarios viejos hablando con un esquema nuevo.

## 6. Verificar

```bash
curl http://127.0.0.1:5000/health          # desde el VPS — "Healthy"
sudo journalctl -u carewell-api -n 50 --no-pager   # que no haya excepciones al arrancar
```
```powershell
curl.exe -I https://api.estecarsoft.com.ar/health   # desde tu PC — debería dar 200 OK
```

> `/health` solo chequea `CareWellDbContext` (`AddDbContextCheck<CareWellDbContext>()` en
> `Program.cs`). El `LogDbContext` **no** está en el health check: que dé `Healthy` no dice
> nada sobre las tablas de log. Para eso, el chequeo de abajo.

Chequeo del pipeline de logs (vale la pena hacerlo la primera vez y cada vez que toques algo
de auditoría). Un login con credenciales inválidas tira `UnauthorizedAccessException`, que el
`ApiResultFilter` traduce a 401 **y registra** como excepción controlada:

```bash
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST http://127.0.0.1:5000/api/Authorization/login \
  -H "Content-Type: application/json" \
  -d '{"email":"no-existe@carewell.test","contrasena":"xxxxxxxx"}'
# Esperado: HTTP 401

/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C -Q \
  "SELECT TOP 5 ID_LogExcepcion, FechaHora, Tipo, Controlada, Ruta FROM t_LogExcepcion ORDER BY ID_LogExcepcion DESC"
# Esperado: una fila nueva con Ruta = /api/Authorization/login y Controlada = 1
```

Si el 401 sale bien pero **no** aparece la fila, buscá en el journal:
`sudo journalctl -u carewell-api -n 50 --no-pager | grep "No se pudo registrar el log"` —
casi seguro faltó correr `efbundle-log` (paso 5.4).

Después, un smoke test rápido desde la app apuntando a producción
(`flutter run --dart-define-from-file=.env.production`): login con un usuario existente y,
si tocaste algo relacionado, el flujo específico que cambiaste.

## 7. Si algo sale mal (rollback)

- **El backend no arranca / rompe algo:** `sudo systemctl status carewell-api` y
  `sudo journalctl -u carewell-api -n 100 --no-pager` para ver el error. Para volver a la
  versión anterior con el backup del paso 5.3:
  ```bash
  sudo systemctl stop carewell-api
  sudo rm -rf /var/www/carewell/api
  sudo mv /var/www/carewell/api.bak /var/www/carewell/api
  sudo chown -R carewell:carewell /var/www/carewell/api
  sudo systemctl start carewell-api
  ```
  Ojo: esto revierte **los binarios**, no la base. Si el deploy incluía migraciones
  destructivas, hay que restaurar también el backup del paso 5.2.
- **Una migración rompió la base:** restaurar el backup del paso 5.2 con `RESTORE DATABASE`
  (con el servicio parado y sin conexiones abiertas a la base). Restaurar la base **revierte
  los dos historiales de migración a la vez** (`__EFMigrationsHistory` y
  `__EFMigrationsHistory_Log`), porque están en la misma base — después del restore hay que
  volver a correr **los dos** bundles.
- **Falló solo el bundle de logs:** no es bloqueante. Podés arrancar el servicio igual (se
  pierden logs de auditoría hasta que lo resuelvas) y volver a correr `efbundle-log` después,
  sin parar nada — solo crea tablas nuevas, no toca el dominio.
- **No sabés qué pasó:** `sudo journalctl -u carewell-api -f` para ver logs en vivo mientras
  reproducís el problema; y `SELECT TOP 20 * FROM t_LogExcepcion ORDER BY ID_LogExcepcion DESC`
  para ver las excepciones con stack trace, ruta y usuario.

## 8. Resumen para el deploy típico (sin migraciones)

```powershell
dotnet publish CareWell.API -c Release -r linux-x64 --self-contained false -o .\publish
scp -P 5323 -r .\publish esteban@66.97.43.117:~/deploy-publish
```
```bash
sudo systemctl stop carewell-api
sudo rm -rf /var/www/carewell/api.bak && sudo cp -r /var/www/carewell/api /var/www/carewell/api.bak
sudo rm -rf /var/www/carewell/api/* && sudo cp -r ~/deploy-publish/* /var/www/carewell/api/
sudo chown -R carewell:carewell /var/www/carewell/api && rm -rf ~/deploy-publish
sudo systemctl start carewell-api && curl http://127.0.0.1:5000/health
```

## 9. Consultar la base desde SSMS (túnel SSH)

El puerto 1433 **no** está abierto al mundo (`ufw` solo tiene 5323, 80 y 443) y SQL Server escucha
únicamente en `localhost`. Para mirar las tablas desde tu PC se tuneliza sobre la conexión SSH que
ya está asegurada por clave. Desde una ventana de PowerShell que dejás abierta mientras trabajás:

```powershell
ssh -p 5323 -L 14330:127.0.0.1:1433 esteban@66.97.43.117
```

Con `-N` (`ssh -p 5323 -N -L 14330:127.0.0.1:1433 esteban@66.97.43.117`) abrís solo el túnel, sin
sesión interactiva. Y en SSMS:

- **Server Name:** `127.0.0.1,14330` — con la IP explícita, no `localhost` (puede resolver a
  `::1`/IPv6 y fallar); tampoco pongas `\SQLEXPRESS`, la instancia del VPS no tiene nombre.
- **Authentication:** SQL Server Authentication, usuario `CareWellAdmin` (la password está en
  `/etc/carewell/carewell.env`).
- **Trust server certificate:** tildado. SSMS 20+ exige encriptación por defecto y el certificado
  de SQL Server es autofirmado — es el equivalente al `-C` de los `sqlcmd` de esta guía.

Cerrando la ventana se corta el túnel y no queda nada expuesto.

Sirve para todas las verificaciones de esta guía (pasos 1, 5.5, 5.6 y 6) sin tener que armar
`sqlcmd` a mano con la password en la línea de comando; por ejemplo, después de migrar:

```sql
SELECT TOP 5 MigrationId FROM __EFMigrationsHistory ORDER BY MigrationId DESC;
SELECT MigrationId FROM __EFMigrationsHistory_Log ORDER BY MigrationId DESC;
SELECT TOP 20 * FROM t_LogExcepcion ORDER BY ID_LogExcepcion DESC;
```

Backups, tamaño de la base y el resto de los comandos: `administracion.md`, sección "Base de datos".
