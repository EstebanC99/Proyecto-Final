# Cómo desplegar una versión actualizada del backend

> **Destinatario:** quien haga el deploy (hoy, el desarrollador backend)
> **Prerrequisito:** el VPS ya está aprovisionado (SSH, SQL Server, .NET Runtime, Caddy,
> systemd) según `care_well_doc/Specs/deploy-vps-donweb.md`. Esta guía es solo para
> **actualizar una versión ya desplegada**, no para la puesta en marcha inicial.

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

## 1. Verificaciones previas

- [ ] ¿Hay migraciones de EF Core nuevas desde el último deploy? (`git log` sobre
      `care_well_backend/CareWell/CareWell.Repository/Migrations/`)
- [ ] ¿Cambió el script de catálogos (`care_well_sql/post-deployment/Carga de datos tablas
      fijas.sql`)? Si agregaste valores nuevos a un catálogo, hay que volver a correrlo (es
      idempotente, no rompe si no cambió nada).
- [ ] `dotnet build CareWell.slnx` y los tests (`dotnet test ...`) en verde localmente.

## 2. Publicar el backend (en tu PC)

Desde `care_well_backend/CareWell/`:

```powershell
dotnet publish CareWell.API -c Release -r linux-x64 --self-contained false -o .\publish
```

## 3. (Solo si hay migraciones nuevas) Generar el migration bundle

```powershell
dotnet ef migrations bundle `
  --project CareWell.Repository `
  --startup-project CareWell.API `
  --self-contained -r linux-x64 `
  -o .\efbundle
```

## 4. Transferir al VPS

```powershell
scp -P 5323 -r .\publish esteban@66.97.43.117:~/deploy-publish
# solo si generaste un bundle nuevo en el paso 3:
scp -P 5323 .\efbundle esteban@66.97.43.117:~/
# solo si cambió el script de catálogos:
scp -P 5323 "D:\Projects\Proyecto-Final\care_well_sql\post-deployment\Carga de datos tablas fijas.sql" esteban@66.97.43.117:~/catalogos.sql
```

## 5. En el VPS: aplicar la actualización

Conectate (`ssh -p 5323 esteban@66.97.43.117`) y seguí este orden — **parar el servicio antes
de tocar los archivos, migrar antes de arrancar de nuevo**:

```bash
# 5.1 Parar el servicio
sudo systemctl stop carewell-api

# 5.2 Backup de la base antes de migrar (por si hay que volver atrás)
sudo /opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -C -Q \
  "BACKUP DATABASE CareWell TO DISK = '/var/opt/mssql/data/CareWell_$(date +%Y%m%d_%H%M).bak'"

# 5.3 (solo si hay bundle nuevo) Aplicar migraciones
chmod +x ~/efbundle
./efbundle --connection 'Server=127.0.0.1;Database=CareWell;User ID=CareWellAdmin;Password=TU_PASSWORD;TrustServerCertificate=True;Encrypt=True;'

# 5.4 (solo si cambió) Recargar catálogos — es idempotente, no hace nada si no cambió nada
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C -i ~/catalogos.sql
rm -f ~/catalogos.sql

# 5.5 Reemplazar los binarios (conserva /etc/carewell y /var/lib/carewell, están fuera de esta carpeta)
sudo rm -rf /var/www/carewell/api/*
sudo cp -r ~/deploy-publish/* /var/www/carewell/api/
sudo chown -R carewell:carewell /var/www/carewell/api
rm -rf ~/deploy-publish ~/efbundle

# 5.6 Arrancar de nuevo
sudo systemctl start carewell-api
sudo systemctl status carewell-api --no-pager
```

## 6. Verificar

```bash
curl http://127.0.0.1:5000/health          # desde el VPS
```
```powershell
curl.exe -I https://api.estecarsoft.com.ar/health   # desde tu PC — debería dar 200 OK
```

Después, un smoke test rápido desde la app apuntando a producción
(`flutter run --dart-define-from-file=.env.production`): login con un usuario existente y,
si tocaste algo relacionado, el flujo específico que cambiaste.

## 7. Si algo sale mal (rollback)

- **Backend no arranca / rompe algo:** `sudo systemctl status carewell-api` y
  `sudo journalctl -u carewell-api -n 100 --no-pager` para ver el error. Si hace falta volver
  a la versión anterior, repetí el paso 2-5 con el commit anterior (no hay carpeta de backup
  automática de binarios — considerá copiar `/var/www/carewell/api` a
  `/var/www/carewell/api.bak` antes del paso 5.5 si el cambio es riesgoso).
- **Migración rompió la base:** restaurar el backup del paso 5.2 con `RESTORE DATABASE`.
- **No sabés qué pasó:** `sudo journalctl -u carewell-api -f` para ver logs en vivo mientras
  reproducís el problema.
