# Administración del servidor de producción

> Comandos de referencia para el día a día del VPS (no para el deploy en sí — eso está en
> `redeploy.md`). Todo corre en el VPS de DonWeb, Ubuntu 22.04 LTS.

## Conexión

```bash
ssh -p 5323 esteban@66.97.43.117
```

El puerto SSH es **5323**, no el 22 (está cerrado a propósito). Login solo por clave — no hay
contraseña configurada para SSH. `root` no puede loguearse por SSH; usá `esteban` + `sudo`.

Para agregar acceso desde un dispositivo nuevo, generá una clave ahí (`ssh-keygen -t ed25519`)
y sumá la pública a `/home/esteban/.ssh/authorized_keys` en el servidor (una clave por línea).

## El servicio de la API

```bash
sudo systemctl status carewell-api --no-pager     # estado
sudo systemctl restart carewell-api               # reiniciar
sudo systemctl stop carewell-api                  # parar
sudo journalctl -u carewell-api -n 100 --no-pager  # últimas 100 líneas de log
sudo journalctl -u carewell-api -f                 # logs en vivo
```

Arranca solo al bootear el VPS (`enabled`). Si se cae, `systemd` lo reinicia automáticamente
(`Restart=always`, cada 10s).

## Caddy (reverse proxy / TLS)

```bash
sudo systemctl status caddy --no-pager
sudo systemctl reload caddy      # aplica cambios de /etc/caddy/Caddyfile sin cortar conexiones
sudo journalctl -u caddy -n 50 --no-pager
```

El certificado TLS se renueva solo (Let's Encrypt, automático). Config en
`/etc/caddy/Caddyfile` — copia de referencia en `Caddyfile` en esta misma carpeta.

## Base de datos (SQL Server Express)

Solo escucha en `localhost` — no es alcanzable desde internet (no está el puerto 1433 abierto
en el firewall).

```bash
# Conectar como el usuario de la app
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C

# Tamaño de la base (SQL Server Express tiene un límite de 10GB por base)
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -d CareWell -C -Q \
  "SELECT SUM(size) * 8 / 1024 AS SizeMB FROM sys.database_files"

# Backup manual
/opt/mssql-tools18/bin/sqlcmd -S localhost -U CareWellAdmin -P 'TU_PASSWORD' -C -Q \
  "BACKUP DATABASE CareWell TO DISK = '/var/opt/mssql/data/CareWell_$(date +%Y%m%d_%H%M).bak'"
```

### Conectarse con SSMS (o Azure Data Studio) desde tu PC

No se abre el puerto 1433 al mundo — se usa un túnel SSH sobre la conexión que ya está
asegurada (puerto 5323, solo por clave). Desde una ventana de PowerShell que dejás abierta
mientras trabajás:

```powershell
ssh -p 5323 -L 14330:127.0.0.1:1433 esteban@66.97.43.117
```

Y en SSMS, conectate con:
- **Server Name:** `127.0.0.1,14330` (con la IP explícita, no `localhost` — puede resolver a
  `::1`/IPv6 y fallar; tampoco pongas `\SQLEXPRESS`, la instancia del VPS no tiene nombre)
- **Authentication:** SQL Server Authentication
- **User:** `CareWellAdmin`

Cerrando la ventana de PowerShell se corta el túnel y no queda nada expuesto.

**Pendiente (deuda):** no hay backup automático programado todavía. Hasta que se configure un
cron / systemd timer, los backups son manuales — hacer uno antes de cada deploy con
migraciones (ver `redeploy.md`) y periódicamente si hay usuarios reales.

## Firewall y seguridad

```bash
sudo ufw status                              # puertos abiertos: 5323, 80, 443 (nada más)
sudo fail2ban-client status sshd             # IPs baneadas por intentos fallidos de SSH
sudo fail2ban-client unban <IP>              # desbanear una IP si fue un falso positivo
```

## Espacio en disco y recursos

```bash
df -h /                # espacio en disco
free -h                # memoria
htop                    # si está instalado; si no, "top"
```

## Configuración de la app (`/etc/carewell/`)

- `carewell.env` — variables de entorno con los secretos (connection string, JWT, SMTP, API
  key de Gemini, ruta a las credenciales de Firebase). **No está versionado.** Plantilla de
  referencia (sin valores reales): `carewell.env.example` en esta carpeta.
- Credenciales de Firebase (JSON de service account) — el nombre de archivo y su ruta exacta
  están apuntados por `Push:RutaCredenciales` dentro de `carewell.env`.

Ambos con permisos `640`, dueño `root:carewell` — solo `root` y el grupo `carewell` pueden
leerlos.

Si editás `carewell.env`, hace falta reiniciar el servicio para que tome los cambios:
```bash
sudo systemctl restart carewell-api
```

## Problemas conocidos

### Historia: por qué el backend usa Vertex AI y no Google AI Studio

En el primer deploy, la API de Gemini vía **Google AI Studio** (`generativelanguage.googleapis.com`)
funcionaba perfecto desde una PC de escritorio pero fallaba desde el VPS con
`400 FAILED_PRECONDITION — "User location is not supported for the API use"`, pese a que la
IP del VPS geolocaliza al mismo país que la PC. Es un bloqueo de Google a IPs de
datacenter/hosting como medida antiabuso — le pasa a cualquier VPS (Hetzner, OVH, InterServer,
DonWeb...), no es algo puntual de esta infraestructura.

Se probó habilitar billing + generar una key nueva (arregla el caso en algunos reportes) y
funcionó un rato, pero **el bloqueo volvió a aparecer más tarde con la misma key**, incluso
contra el endpoint nativo que ya había respondido bien antes. Es decir: **no es un problema
resoluble de forma estable desde el lado de AI Studio**, es intermitente por diseño para ese
producto.

**Solución final: usar Vertex AI / Agent Platform en vez de AI Studio.** Es el producto de
Google pensado específicamente para uso servidor-a-servidor y no aplica esa restricción. El
backend le habla directo (`GeminiChatClient.cs` en `CareWell.DocumentIntelligence`, sin SDK de
terceros) al endpoint `https://aiplatform.googleapis.com/v1/publishers/google/models/{modelo}:generateContent`,
con la key en el header `x-goog-api-key` (no como query param `?key=`, así se autentica AI
Studio).

**Gotchas al generar la API key en Google Cloud Console:**
- El menú "Agent Platform" tiene varias claves con distinto scope. Hace falta una con
  restricción **"Gemini API"** (o Vertex AI) — una con restricción "Agent Platform API" a
  secas es *otro producto* y da `403 PERMISSION_DENIED / API_KEY_SERVICE_BLOCKED`.
- Vertex exige el campo `"role": "user"` en cada content del request (a diferencia de AI
  Studio, que lo infiere si falta) — si falta, da `400 INVALID_ARGUMENT`.
- Los nombres de modelo con sufijo `-latest` (alias de AI Studio) no existen en el catálogo de
  Vertex — da `404 NOT_FOUND`. Usar el nombre versionado directo, ej. `gemini-2.5-flash-lite`.
- `gemini-2.5-flash` (sin `-lite`) tiene "thinking" activado por defecto y agrega latencia
  innecesaria para estas tareas de extracción simple — usar la variante `-lite`.

Test rápido para diagnosticar esto (sin exponer la key en la terminal más de lo necesario):
```bash
API_KEY=$(sudo grep '^IA__ApiKey=' /etc/carewell/carewell.env | cut -d= -f2-)
curl -s -o /tmp/gemini-test.json -w "HTTP %{http_code}\n" \
  -X POST "https://aiplatform.googleapis.com/v1/publishers/google/models/gemini-2.5-flash-lite:generateContent" \
  -H "x-goog-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"role":"user","parts":[{"text":"Respondé con la palabra OK."}]}]}'
cat /tmp/gemini-test.json
rm /tmp/gemini-test.json
```
`HTTP 200` con una respuesta = todo bien.

## Zona horaria

El sistema está en `America/Argentina/Buenos_Aires` (`timedatectl` para confirmar). Importante
porque el dominio usa `DateTime.Now`/`DateTime.Today` en varios lados — si algún día se migra
el VPS o se reinstala, hay que volver a fijarla:
```bash
sudo timedatectl set-timezone America/Argentina/Buenos_Aires
```
