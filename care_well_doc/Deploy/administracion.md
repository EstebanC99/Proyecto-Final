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

### Proveedor de IA: configuración por ambiente

El backend le habla directo al **REST nativo de Gemini** (`GeminiChatClient.cs` en
`CareWell.DocumentIntelligence`, sin SDK de terceros) y soporta **dos proveedores**, que se
seleccionan con la variable `IA__Proveedor`:

| `IA__Proveedor` | URL base | Dónde se usa |
| --- | --- | --- |
| `VertexAI` (default) | `https://aiplatform.googleapis.com/v1/publishers/google/models` | **Producción** (este VPS) |
| `AIStudio` | `https://generativelanguage.googleapis.com/v1beta/models` | **Desarrollo** local, con API key de nivel gratuito (sin costo) |

Los dos hablan el **mismo protocolo REST** y se autentican igual —la key va en el header
`x-goog-api-key`, no como query param `?key=`—, y difieren **únicamente en la URL base**, que
resuelve `DocumentIntelligenceExtensions.ResolverBaseUrl`. Por eso hay un único
`GeminiChatClient`, sin ramas por ambiente. El valor lo fija `appsettings.{Ambiente}.json`
(`VertexAI` en `Production`, `AIStudio` en `Development`) y en el VPS puede pisarse desde
`carewell.env`. Existe además `IA__BaseUrlPersonalizada`, que permite fijar la URL base a mano
(proxy, otra versión de la API) y tiene precedencia sobre el proveedor elegido.

> ⚠️ **Advertencia de datos.** El **nivel gratuito de AI Studio emplea las consignas enviadas
> para entrenar los modelos de Google**. Por eso `AIStudio` es exclusivamente para desarrollo y
> **solo con datos ficticios**: nunca datos reales de personas y mucho menos datos de salud. Las
> garantías de no-entrenamiento y el *Cloud Data Processing Addendum* en los que se apoya el
> documento del proyecto son propias de la **plataforma empresarial** (Vertex AI) y no del
> servicio gratuito de uso general — ver `CuidadoPersonas.tex`, subsecciones "Componente de
> inteligencia artificial" y "Resumen diario de la persona a cargo". **Producción va siempre por
> `VertexAI`.**

**`IA__EnviarResponseSchema` (default `true`) — interruptor de rollback.** Con el valor por
defecto, el cliente le manda al modelo el JSON Schema de la respuesta esperada (previamente
saneado al subconjunto de keywords que Gemini acepta) dentro de
`generationConfig.responseJsonSchema`, forzando una salida estructurada. Si un cambio de esquema
—una entidad nueva, un tipo distinto en un *response*— hace que Gemini empiece a devolver
`400 INVALID_ARGUMENT`, ponerlo en `false` es la vía rápida de rollback: se sigue pidiendo
`application/json`, pero sin esquema, y la respuesta se parsea igual desde el texto quedando la
estructura a cargo del *system prompt*. Es un mitigante temporal: la corrección de fondo es
identificar el keyword culpable —se ve en el request guardado en `LogServicioExterno`— y
agregarlo a `KeywordsNoSoportados` en `GeminiChatClient`.

**Gotchas al generar la API key de Vertex AI en Google Cloud Console:**
- El menú "Agent Platform" tiene varias claves con distinto scope. Hace falta una con
  restricción **"Gemini API"** (o Vertex AI) — una con restricción "Agent Platform API" a
  secas es *otro producto* y da `403 PERMISSION_DENIED / API_KEY_SERVICE_BLOCKED`.
- Vertex exige el campo `"role": "user"` en cada content del request (a diferencia de AI
  Studio, que lo infiere si falta) — si falta, da `400 INVALID_ARGUMENT`.
- Los nombres de modelo con sufijo `-latest` (alias de AI Studio) no existen en el catálogo de
  Vertex — da `404 NOT_FOUND`. Usar el nombre versionado directo, ej. `gemini-2.5-flash-lite`.
- `gemini-2.5-flash` (sin `-lite`) tiene "thinking" activado por defecto y agrega latencia
  innecesaria para estas tareas de extracción simple — usar la variante `-lite`.

**Test rápido del proveedor** (sin exponer la key en la terminal más de lo necesario). Como el
protocolo es el mismo para los dos proveedores, alcanza con cambiar `BASE_URL` para probar uno u
otro:
```bash
API_KEY=$(sudo grep '^IA__ApiKey=' /etc/carewell/carewell.env | cut -d= -f2-)

# Vertex AI (producción)
BASE_URL=https://aiplatform.googleapis.com/v1/publishers/google/models
# AI Studio (desarrollo): BASE_URL=https://generativelanguage.googleapis.com/v1beta/models

curl -s -o /tmp/gemini-test.json -w "HTTP %{http_code}\n" \
  -X POST "$BASE_URL/gemini-2.5-flash-lite:generateContent" \
  -H "x-goog-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"role":"user","parts":[{"text":"Respondé con la palabra OK."}]}]}'
cat /tmp/gemini-test.json
rm /tmp/gemini-test.json
```
`HTTP 200` con una respuesta = todo bien. Un `400`/`403` acá, con la misma key que usa el
servicio, indica que el problema es de la **key** (proyecto, facturación o restricciones) y no
del backend — ver el registro de diagnóstico en "Problemas conocidos".

## Problemas conocidos

### El `400 FAILED_PRECONDITION` del primer deploy (diagnóstico corregido)

Se conserva el registro porque explica por qué el proyecto terminó con dos proveedores
soportados, y para no volver a diagnosticar mal el mismo error.

**Síntoma.** En el primer deploy, las llamadas a Gemini vía **AI Studio**
(`generativelanguage.googleapis.com`) funcionaban desde una PC de escritorio pero fallaban desde
el VPS con `400 FAILED_PRECONDITION — "User location is not supported for the API use"`, pese a
que la IP del VPS geolocaliza al mismo país que la PC. Se probó habilitar billing y generar una
key nueva: funcionó un rato y volvió a fallar.

**Diagnóstico original — incorrecto.** Se atribuyó la falla a un bloqueo antiabuso de Google a
las IPs de datacenter/hosting y se concluyó que no era un problema "resoluble de forma estable
desde el lado de AI Studio". Sobre esa base se migró a Vertex AI.

**Corrección.** Esa causa raíz **no era la correcta**: el `FAILED_PRECONDITION` provenía de la
**API key utilizada** —su proyecto, facturación y restricciones asociadas—, no de la IP de
origen. Con una key correctamente configurada, el endpoint de AI Studio responde con normalidad;
de hecho el ambiente de desarrollo lo usa hoy de forma habitual. Lo que desorientó el
diagnóstico fue que la key nueva "funcionó un rato": esa intermitencia se leyó como un bloqueo
por IP cuando era un problema de la propia key.

**Qué sigue en pie.** Usar **Vertex AI en producción continúa siendo la decisión correcta**,
pero por motivos distintos de los que se creyó en su momento: es el producto pensado para uso
servidor-a-servidor y, sobre todo, **es el que ofrece las garantías de tratamiento de datos**
—no entrenamiento con las consignas y *Cloud Data Processing Addendum*— que el proyecto exige
para manejar datos de salud. Dejó de ser un rodeo técnico para pasar a ser una decisión de
privacidad. Los *gotchas* de Vertex documentados más arriba siguen todos vigentes.

## Zona horaria

El sistema está en `America/Argentina/Buenos_Aires` (`timedatectl` para confirmar). Importante
porque el dominio usa `DateTime.Now`/`DateTime.Today` en varios lados — si algún día se migra
el VPS o se reinstala, hay que volver a fijarla:
```bash
sudo timedatectl set-timezone America/Argentina/Buenos_Aires
```
