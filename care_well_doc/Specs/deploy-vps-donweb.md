# Deploy de CareWell en VPS DonWeb — plan de puesta en producción

> **Destinatario:** usuario (dueño del proyecto) / futuro `dev-flutter` o desarrollador backend que ejecute el deploy
> **Autor:** `arquitecto-software`
> **Estado:** **ejecutado (2026-08-06) — deploy inicial en producción funcionando.** Este documento es el plan original; quedó como referencia histórica de las decisiones y del razonamiento, pero **la sección A (proveedor de IA) cambió durante la ejecución** — ver nota al principio de esa sección. Para el estado operativo real, comandos de administración y runbook de redeploy, la fuente de verdad es `care_well_doc/Deploy/` (`redeploy.md`, `administracion.md`).
> **Origen:** pedido del usuario de analizar qué hace falta para hostear CareWell en un VPS de DonWeb (2026-08-06)
> **Alcance:** deploy del backend (.NET 10 API + SQL Server) en el VPS. La app Flutter no se hostea acá — va a stores.

---

## 0. Decisiones confirmadas (no reabrir sin motivo)

| Punto | Decisión |
|---|---|
| VPS | Ya contratado — 8-16 GB RAM, Linux (Ubuntu) |
| IA (OCR de DNI + resumen diario) | API externa en vez de Ollama local. Default recomendado: **Google Gemini** (free tier). Anthropic (Claude) como plan B pago — la licencia de Claude.ai **no** cubre la API de Anthropic, son productos y facturación separados |
| Base de datos | SQL Server Express definitivo (no se migra a PostgreSQL) |
| Dominio | Ya existe uno propio para la API |
| Método de deploy | **Directo**: systemd + `dotnet publish`. NO Docker |
| Ambientes | Solo producción, sin staging |
| CI/CD | Manual por ahora, sin GitHub Actions |
| Push FCM (emergencias) | En alcance, crítico. Ya está implementado en el código (`CareWell.Notifications/Push/FirebasePushSender.cs`) — el `CLAUDE.md` dice "reservado a futuro", está desactualizado en ese punto |
| Protección de datos (Ley 25.326) | No es requisito formal de la tesis |
| Visibilidad del repo | Privado — baja la urgencia de rotar secretos filtrados, no la elimina |

Con IA externa (sin Ollama local), el presupuesto de RAM es holgado: API (~0.5GB) + SQL Server Express (~2-2.5GB) + SO (~0.5GB) ≈ 3-3.5GB sobre un VPS de 8-16GB.

---

## A) Proveedor de IA recomendado

> **⚠️ Actualización post-ejecución (2026-08-06):** lo de abajo fue el análisis y la decisión
> *antes* de desplegar. En producción, **Google AI Studio resultó bloquear de forma
> intermitente las llamadas desde la IP del VPS** (`400 FAILED_PRECONDITION — "User location
> is not supported for the API use"`), incluso con billing habilitado y una key nueva — es un
> bloqueo antiabuso conocido de Google a IPs de datacenter/hosting, no arreglable de forma
> confiable desde ese lado. **Se migró a Vertex AI / Agent Platform** (mismo modelo Gemini,
> pero el producto de Google pensado para uso servidor-a-servidor, sin esa restricción).
> **Corrección posterior:** ese diagnóstico resultó equivocado —la falla era de la API key, no
> de la IP del VPS— y hoy se soportan los dos proveedores (`IA__Proveedor`), aunque producción
> sigue yendo por Vertex AI por las garantías de tratamiento de datos. Detalle completo,
> incluidos los gotchas de autenticación y nombres de modelo, en
> `care_well_doc/Deploy/administracion.md` → "Proveedor de IA: configuración por ambiente" y
> "Problemas conocidos". El resto de este documento
> (por qué Gemini como familia de modelos, en vez de otro proveedor) sigue siendo válido; lo
> que cambió es *cómo* se accede a Gemini, no la elección de Gemini en sí.

### Aclaración previa importante

Tu licencia de **Claude (claude.ai / Claude Code) NO habilita la API de Anthropic**. Son productos y facturaciones separadas: la API se paga aparte con créditos en `console.anthropic.com`, por token consumido. Si se va por Anthropic, es un gasto nuevo, no algo cubierto por lo que ya se paga.

### Recomendación: Google Gemini (free tier) como default, vía cliente OpenAI-compatible

**Por qué Gemini:**
- Tiene **free tier real** en Google AI Studio, suficiente para carga de proyecto estudiantil (verificar los límites RPM/RPD vigentes al momento de configurarlo, cambian seguido).
- Los modelos Flash soportan **visión** (OCR de DNI) y **structured output con JSON schema** (que es justo lo que necesita `GetResponseAsync<ReconocedorTextoDocumentoAgentResponse>`).
- Un modelo Flash-Lite para el resumen diario y un Flash para OCR resuelven la separación de dos modelos que pide `CLAUDE.md` y que hoy no se cumple (hoy hay un solo `IChatClient` de Ollama compartido).
- Latencia de segundos en vez de minutos: desaparece el riesgo de timeout en el registro.

**Caveat de privacidad:** en el free tier de Google los datos pueden usarse para mejorar el producto. Se están mandando **imágenes de DNI**. Para una tesis es aceptable, pero dejarlo escrito como limitación conocida y considerar pasar a tier pago (que no entrena con los datos) si alguna vez hay usuarios reales.

**Alternativa: Anthropic (Claude).** Mejor calidad de instrucción y muy buena visión, pero pago desde el primer token y sin free tier. Trade-off: si el OCR de DNI con Gemini Flash da tasa de error alta en documentos reales, Claude es el plan B natural — y con el diseño de abajo el cambio es **solo configuración**, no código.

### Cómo integrarlo: `Microsoft.Extensions.AI.OpenAI` apuntado al endpoint compatible

En vez de un paquete específico de Gemini (los que existen son de comunidad: `Mscc.GenerativeAI.Microsoft`, `Anthropic.SDK`), usar el cliente OpenAI oficial apuntado al **endpoint OpenAI-compatible** del proveedor. Gemini expone `https://generativelanguage.googleapis.com/v1beta/openai/` y Anthropic expone su capa de compatibilidad en `https://api.anthropic.com/v1/`. Así, **el mismo código sirve para Gemini, Anthropic, OpenAI, Groq u OpenRouter** cambiando URL + modelo + API key en configuración.

**Paquetes NuGet** en `care_well_backend/CareWell/CareWell.DocumentIntelligence/CareWell.DocumentIntelligence.csproj`:
- Quitar: `OllamaSharp` (5.4.27).
- Agregar: `Microsoft.Extensions.AI` (hoy entra transitivamente por OllamaSharp; al sacarlo hay que referenciarlo explícito), `Microsoft.Extensions.AI.OpenAI`, y `Microsoft.Extensions.DependencyInjection.Abstractions` (para el atributo `FromKeyedServices`).

**Archivos a tocar:**

1. `CareWell.DocumentIntelligence/OllamaClientOptions.cs` → renombrar a `IAOptions.cs` con:
   `Endpoint`, `ApiKey`, `ModeloVision`, `ModeloTexto`, `TimeoutSegundos`.

2. `CareWell.DocumentIntelligence/DocumentIntelligenceExtensions.cs` (líneas 14-31) → reemplazar el `AddSingleton<IChatClient>` de Ollama por **dos clientes keyed**:
   - `AddKeyedSingleton<IChatClient>("vision", ...)` → `new OpenAIClient(new ApiKeyCredential(apiKey), new OpenAIClientOptions { Endpoint = new Uri(opciones.Endpoint) }).GetChatClient(opciones.ModeloVision).AsIChatClient()`
   - `AddKeyedSingleton<IChatClient>("texto", ...)` → idem con `ModeloTexto`.

   Esto elimina el problema actual de un único modelo de visión pesado haciendo también el resumen.

3. `ReconocedorTextoDocumentoAgent.cs` y `ResumidorDiarioAgent.cs` → **solo el constructor**, agregando `[FromKeyedServices("vision")]` / `[FromKeyedServices("texto")]` al parámetro `IChatClient`. Los system prompts y la lógica no se tocan.

4. **Cambio de fondo en el manejo de errores de `ReconocedorTextoDocumentoAgent.cs` (líneas 60-69).** El filtro actual:
   ```csharp
   catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or OperationCanceledException)
       throw new ServicioNoDisponibleException(...);
   catch { return null; }
   ```
   El SDK de OpenAI **no lanza `HttpRequestException`** ante errores HTTP: lanza `System.ClientModel.ClientResultException`. Con el código tal cual está, un **429 (cuota agotada del free tier) o un 500 del proveedor caen en el `catch { return null; }`** y el usuario ve "no se pudo leer el DNI" en vez de "servicio no disponible". Hay que agregar `ClientResultException` al filtro (idealmente distinguiendo 4xx de validación de 429/5xx).

5. `CareWell.API/Program.cs` línea 39: `Configure<OllamaClientOptions>(GetSection("Ollama"))` → `Configure<IAOptions>(GetSection("IA"))`.

6. Opcional pero recomendado: `ExtraerTexto` es **sync-over-async** (`.GetAwaiter().GetResult()`, línea 53-56) y sin `CancellationToken`. Con una API remota eso bloquea un thread del pool durante toda la llamada. Convertirlo a `Task<...>` propaga cambios al BusinessService y al controller — dejarlo como ítem posterior si se quiere desplegar antes, pero anotado.

---

## B) Checklist de seguridad priorizado

### Crítico (antes de exponer el dominio)

1. **Rotar los 3 secretos filtrados:**
   - **JWT key**: generar una nueva de ≥32 bytes aleatorios (`openssl rand -base64 48`). Consecuencia: invalida todos los tokens vigentes, todos los usuarios deben re-loguearse. Irrelevante hoy.
   - **Password SMTP**: regenerar la credencial en el panel de Elastic Email y revocar la vieja.
   - **Password de BD**: en producción usar un usuario/password nuevos. Ojo: `care_well_sql/Creacion de Usuario-Rol-BD.sql` tiene hardcodeado `CREATE LOGIN CareWellAdmin WITH PASSWORD = 'Pass@word1!!'`. Ese script **no debe usarse tal cual en producción**: parametrizar la password o dejar un placeholder.

2. **Sacar `care_well_secrets/user-secrets.txt` del tracking**: `git rm --cached`, agregar `care_well_secrets/` al `.gitignore`, y dejar en su lugar un `user-secrets.example.txt` con placeholders.

3. **¿Purgar el historial de git?** **No, no vale la pena.** Justificación: el repo es privado, el blast radius son los colaboradores del repo (que ya tenían acceso), y una vez rotados los secretos los valores del historial son inertes. Purgar con `git filter-repo`/BFG reescribe todos los hashes, invalida clones y forks, y complica el trabajo con los otros integrantes por un beneficio casi nulo. **Regla de corte:** si alguna vez se hace el repo público (por ejemplo, para la defensa de la tesis o el portfolio), **ahí sí purgar antes de cambiar la visibilidad**, y rotar de nuevo.

### Importante (primera semana de prod)

4. **Superficie de red**: `ufw` con solo 22, 80 y 443 abiertos. **SQL Server escuchando únicamente en `127.0.0.1`** — nunca exponer 1433 a internet.
5. **SSH**: solo clave pública, `PermitRootLogin no`, `PasswordAuthentication no`, `fail2ban` para SSH.
6. **Rate limiting** en la API con el middleware **nativo** de ASP.NET Core (`AddRateLimiter`, sin librerías externas). Prioridad: login, registro, reset de contraseña (protege el SMTP pago) y los dos endpoints de IA (protege la cuota del free tier).
7. **ForwardedHeaders con `KnownProxies` restringido a `127.0.0.1`** — si se deja abierto, cualquiera puede spoofear su IP y saltarse el rate limiting.
8. **Data Protection keys**: con un usuario de systemd sin home, las claves se regeneran en cada reinicio. Persistirlas en `/var/lib/carewell/keys` con `PersistKeysToFileSystem`.

### Menor

9. Quitar el header `Server` de Kestrel (`AddServerHeader = false`).
10. HSTS habilitado en el proxy.
11. Revisar que los logs no escriban PII (DNI, emails completos, tokens FCM).
12. `LogInterceptor` de `dio_client.dart` en la app Flutter: sacarlo del build de release (loguea tokens y base64 del DNI). No bloquea el deploy del backend, pero sí el release de la app.

---

## C) Deploy directo en Ubuntu (systemd + `dotnet publish`)

### C.1 Sistema operativo y SQL Server — decisión previa

Este es el punto que puede obligar a reinstalar el VPS, así que resolverlo **primero**:

- Microsoft publica paquetes de SQL Server para **versiones de Ubuntu LTS específicas**. SQL Server 2022 está soportado en Ubuntu 20.04/22.04; el soporte de 24.04 llegó con la generación siguiente. **Antes de instalar nada, verificar qué repositorio de Microsoft existe para la versión exacta de Ubuntu del VPS** (`https://packages.microsoft.com/config/ubuntu/<version>/`).
- **Regla de decisión:** si el VPS trae 22.04 → SQL Server 2022 Express nativo, camino más trillado. Si trae 24.04 y no hay repo compatible → pedir a DonWeb reinstalar con 22.04, o correr **solo la base de datos** en un contenedor Docker (la imagen oficial `mcr.microsoft.com/mssql/server` es el camino soportado). Correr la BD en Docker no contradice la decisión de deploy directo: la API sigue en systemd.
- Elegir **Express** (gratis, límite 10GB por base y 1410MB de RAM de buffer pool). Con `VARBINARY(MAX)` para las imágenes de personas, los 10GB son suficientes por mucho tiempo pero **no son infinitos** — anotar el monitoreo del tamaño de base como tarea recurrente.

### C.2 Instalación

```bash
# .NET: ASP.NET Core Runtime 10.0 (NO el SDK: no hace falta en el VPS)
# Usar dotnet-install.sh para no depender del repo de la distro:
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0 --runtime aspnetcore --install-dir /usr/share/dotnet
ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet
```
Cuidado conocido: en Ubuntu 24.04 los paquetes `dotnet` de la distro y los de `packages-microsoft-prod` entran en conflicto. Instalar por script en `/usr/share/dotnet` evita ese lío.

SQL Server Express: paquete `mssql-server`, `sudo /opt/mssql/bin/mssql-conf setup` eligiendo **Express**, y luego `mssql-tools18` para `sqlcmd`. Configurar `mssql-conf set network.ipaddress 127.0.0.1`.

### C.3 Estructura de carpetas

```
/var/www/carewell/api/          # salida de dotnet publish (owner: carewell, solo lectura)
/var/lib/carewell/keys/         # Data Protection keys (0700 carewell)
/etc/carewell/                  # 0750 root:carewell
/etc/carewell/carewell.env      # 0640 root:carewell — secretos como env vars
/etc/carewell/firebase-sa.json  # 0640 root:carewell — credenciales FCM (ver sección E)
/var/log/carewell/              # si se escribe a archivo; si no, journald alcanza
```

Usuario de servicio sin shell: `sudo useradd --system --no-create-home --shell /usr/sbin/nologin carewell`.

### C.4 Publicación (desde la máquina de desarrollo Windows)

```powershell
cd D:\Projects\Proyecto-Final\care_well_backend\CareWell
dotnet publish CareWell.API -c Release -r linux-x64 --self-contained false -o .\publish
```
Y subir `publish/` por `scp`/`rsync` a `/var/www/carewell/api/`. Verificar que **no viajen** `appsettings.Development.json` ni ningún archivo con secretos.

### C.5 Configuración sin secretos en git

Tres capas:
1. `appsettings.json` — valores no sensibles con placeholders (ya existe así, bien).
2. `appsettings.Production.json` — **versionado, sin secretos**: hosts, puertos, nombres de modelos, timeouts, niveles de log.
3. `/etc/carewell/carewell.env` — **solo secretos**, fuera de git, con la convención de doble guión bajo:

```env
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://127.0.0.1:5000
TZ=America/Argentina/Buenos_Aires
ConnectionStrings__CareWellDb=Server=127.0.0.1;Database=CareWell;User ID=...;Password=...;TrustServerCertificate=True;Encrypt=True;
Jwt__Key=...
Email__Password=...
IA__ApiKey=...
Push__RutaCredenciales=/etc/carewell/firebase-sa.json
```

Nota sobre `dotnet user-secrets`: **no funciona en Production**, es exclusivo de Development. No usarlo en el VPS.

### C.6 Unidad de systemd

`/etc/systemd/system/carewell-api.service`:

```ini
[Unit]
Description=CareWell API
After=network.target mssql-server.service

[Service]
WorkingDirectory=/var/www/carewell/api
ExecStart=/usr/local/bin/dotnet /var/www/carewell/api/CareWell.API.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
User=carewell
EnvironmentFile=/etc/carewell/carewell.env
SyslogIdentifier=carewell-api

# Hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/var/lib/carewell /var/log/carewell

[Install]
WantedBy=multi-user.target
```

`TZ` va en el `EnvironmentFile` (o acá con `Environment=TZ=...`) y es el fix mínimo para los 38 `DateTime.Now`. **Adicionalmente** poner el sistema entero en esa zona (`timedatectl set-timezone America/Argentina/Buenos_Aires`) para que los logs y `cron`/`systemd timers` coincidan.

### C.7 Reverse proxy: **Caddy**

**Recomendado: Caddy**, con este razonamiento: TLS automático de Let's Encrypt **incluido con renovación automática y sin certbot ni cron adicional**, HTTP→HTTPS por defecto, `X-Forwarded-*` seteados por defecto, y una configuración de 8 líneas. Para un proyecto de una sola API y un solo dominio, mantenido por una persona, la reducción de superficie operativa es el argumento decisivo.

`/etc/caddy/Caddyfile`:
```
api.tudominio.com {
    encode gzip
    request_body {
        max_size 12MB
    }
    reverse_proxy 127.0.0.1:5000 {
        transport http {
            read_timeout 120s
            write_timeout 120s
        }
    }
}
```

**Alternativa: nginx.** Elegirlo si se prefiere documentación más abundante, o si el soporte de DonWeb solo ayuda con nginx. Los dos ajustes que sí o sí hay que cambiar respecto del default:
```nginx
client_max_body_size 12m;   # default 1m -> daría 413 con el DNI en base64
proxy_read_timeout 120s;    # default 60s
proxy_send_timeout 120s;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```
Con nginx se suma certbot + su timer de renovación.

**En ambos casos:** Kestrel escucha solo en `127.0.0.1:5000`, sin HTTPS propio. TLS termina en el proxy.

### C.8 DNS

Apuntar un registro `A` del subdominio de la API a la IP del VPS **antes** de arrancar Caddy, porque la emisión del certificado requiere que el dominio ya resuelva.

---

## D) Migraciones EF Core + catálogos en producción

### Recomendación: **migration bundle**, no `dotnet ef database update` en el VPS

Motivo: `dotnet ef` requiere el **SDK completo** y el código fuente en el servidor; el bundle es un ejecutable autocontenido que solo necesita la connection string. Además, `dotnet ef` acá necesitaría `--startup-project CareWell.API` (no hay `IDesignTimeDbContextFactory` en la solución), lo que arrastraría toda la configuración de la API al servidor.

**Generación (en la máquina de desarrollo):**
```powershell
cd D:\Projects\Proyecto-Final\care_well_backend\CareWell
dotnet ef migrations bundle `
  --project CareWell.Repository `
  --startup-project CareWell.API `
  --self-contained -r linux-x64 `
  -o .\efbundle
```

**Ejecución (en el VPS):**
```bash
chmod +x ./efbundle
./efbundle --connection "Server=127.0.0.1;Database=CareWell;User ID=...;Password=...;TrustServerCertificate=True;"
```

### Secuencia y momento

**Siempre antes de arrancar/reiniciar el servicio**, nunca en paralelo:

1. Crear login/usuario/BD con una versión adaptada de `care_well_sql/Creacion de Usuario-Rol-BD.sql` (con password fuerte, no la del script).
2. `systemctl stop carewell-api` (en la primera instalación aún no existe).
3. Backup de la base (desde el segundo deploy en adelante: `BACKUP DATABASE` a disco antes de cada bundle).
4. Correr el `efbundle`.
5. Correr el script de catálogos.
6. `systemctl start carewell-api`.

**No agregar `Migrate()` en `Program.cs`.** Que las migraciones no corran en el arranque es correcto y hay que mantenerlo así: evita que un reinicio inesperado altere el esquema y que dos instancias compitan.

### Ojo con el script de catálogos

`care_well_sql/post-deployment/Carga de datos tablas fijas.sql` usa `SET IDENTITY_INSERT ... ON` + `INSERT` directo **sin chequeo de existencia**. Si se corre dos veces, falla por PK duplicada (o deja datos inconsistentes si falla a mitad). **Tarea previa al deploy:** convertirlo a idempotente con `MERGE` o `IF NOT EXISTS (SELECT 1 FROM t_X WHERE ID = n)`. Con eso se puede re-ejecutar en cada deploy sin pensar, y además queda listo para cuando se agreguen valores nuevos a un catálogo.

---

## E) Credenciales de Firebase en el VPS

**Recomendado: archivo, no `CredencialesJson` inline.**

- El JSON del service account es **multilínea** y contiene comillas y `\n` escapados dentro de `private_key`. Los `EnvironmentFile` de systemd **no soportan valores multilínea** y el escaping es frágil: un error silencioso ahí deja `PushSenderNulo` activo y **las notificaciones de emergencia dejan de funcionar sin ruido** (ver `NotificationsExtensions.cs`, el fallback degrada en silencio).
- Las variables de entorno son legibles vía `/proc/<pid>/environ` y aparecen en volcados de proceso; un archivo con permisos 0640 es al menos igual de seguro y mucho más manejable.
- El caso donde inline gana es PaaS/contenedores sin disco persistente, que no es este caso.

**Procedimiento:**
1. Descargar el JSON del service account desde Firebase Console → Configuración del proyecto → Cuentas de servicio.
2. Subirlo por `scp` a `/etc/carewell/firebase-sa.json`.
3. `sudo chown root:carewell /etc/carewell/firebase-sa.json && sudo chmod 640 /etc/carewell/firebase-sa.json` (el directorio `/etc/carewell` en `0750 root:carewell`).
4. En `carewell.env`: `Push__RutaCredenciales=/etc/carewell/firebase-sa.json` y dejar `Push__CredencialesJson` vacío (el código de `NotificationsExtensions.cs` prioriza el inline si está seteado).
5. **Nunca** dentro de `/var/www/carewell/api/` — esa carpeta se sobrescribe en cada publish y podría quedar servida por el proxy si algún día se agregan archivos estáticos.
6. Backupearlo aparte (fuera del VPS y fuera del repo). Si se pierde, se regenera desde Firebase Console.

**Validación adicional a implementar:** hoy, si las credenciales faltan o están mal, se registra `PushSenderNulo` y todo "funciona" sin push. Para una feature crítica como emergencias, agregar al arranque un chequeo que **loguee en nivel Critical** si `PushOptions.EstaConfigurado` es `false` en `Production`. Y probar un envío real de push apenas termine el deploy.

---

## F) Qué falta escribir/tocar en el repo antes de deployar

| # | Ítem | Archivo(s) | Prioridad |
|---|---|---|---|
| 1 | `appsettings.Production.json` de referencia, sin secretos | `care_well_backend/CareWell/CareWell.API/` | Bloqueante |
| 2 | `UseForwardedHeaders()` como **primer** middleware, con `ForwardedHeaders.XForwardedFor \| XForwardedProto` y `KnownProxies = 127.0.0.1`; revisar si conviene quitar `UseHttpsRedirection()` (el proxy ya redirige) | `CareWell.API/Program.cs` líneas 87-99 | Bloqueante |
| 3 | Cambio de proveedor de IA (sección A): quitar `OllamaSharp`, agregar `Microsoft.Extensions.AI.OpenAI`, renombrar `OllamaClientOptions`→`IAOptions`, dos clientes keyed, `[FromKeyedServices]` en los 2 agents, `ClientResultException` en el catch, sección `IA` en `Program.cs:39` | `CareWell.DocumentIntelligence/*` + `Program.cs:39` | Bloqueante |
| 4 | Endpoint de health: `AddHealthChecks().AddDbContextCheck<CareWellDbContext>()` y `MapHealthChecks("/health")`. **Ojo:** hay `SetFallbackPolicy(RequireAuthenticatedUser)` en `Program.cs:75`, así que el endpoint necesita `.AllowAnonymous()` explícito o devolverá 401 | `CareWell.API/Program.cs` | Bloqueante |
| 5 | Script de catálogos idempotente | `care_well_sql/post-deployment/Carga de datos tablas fijas.sql` | Bloqueante |
| 6 | Untrack de `care_well_secrets/` + `.gitignore` + archivo `.example` | raíz del repo | Bloqueante |
| 7 | Data Protection: `PersistKeysToFileSystem(new DirectoryInfo("/var/lib/carewell/keys"))` solo en Production | `CareWell.API/Program.cs` | Alta |
| 8 | Rate limiting nativo (`AddRateLimiter` + `UseRateLimiter`) en auth, reset de password y endpoints de IA | `CareWell.API/Program.cs` + controllers | Alta |
| 9 | Log Critical al arranque si `PushOptions.EstaConfigurado == false` en Production | `CareWell.Notifications/NotificationsExtensions.cs` o `Program.cs` | Alta |
| 10 | Zona horaria: `TZ` en systemd cubre el corto plazo. **Deuda técnica real:** migrar los 38 `DateTime.Now` a `TimeProvider` inyectado, para poder testear ventanas de tiempo y no depender de la config del host | `CareWell.BusinessService/*`, `CareWell.Domain/*` | Media (deuda) |
| 11 | Quitar `LogInterceptor` del build de release | `care_well_app/lib/.../dio_client.dart` | Media (bloquea release de la app, no del backend) |
| 12 | `ExtraerTexto` sync→async con `CancellationToken` | `ReconocedorTextoDocumentoAgent.cs` + BusinessService + controller | Media |
| 13 | README: claves de config de IA (hoy documenta `ReconocedorTexto:*`, el código bindea otra sección) | README del backend | Baja |

---

## G) Orden recomendado de ejecución

**Fase 0 — Decisiones y cuentas (sin código, hacer ya porque tiene lead time)**
1. Verificar versión de Ubuntu del VPS y **confirmar compatibilidad con SQL Server** (sección C.1). Si hay que reinstalar el SO, mejor saberlo ahora.
2. Crear cuenta en Google AI Studio y obtener API key de Gemini. Probar a mano una llamada de visión con una foto de DNI para validar calidad de OCR **antes** de escribir código.
3. Apuntar el registro DNS `A` del subdominio de la API a la IP del VPS (la propagación tarda).

**Fase 1 — Cambios en el repo (en paralelo con Fase 0)**
4. Ítem 6 de la tabla (untrack de secretos) + rotación de los 3 secretos (sección B.1-B.2). Primero esto, porque todo lo demás va a consumir los valores nuevos.
5. Ítem 3 (proveedor de IA). Es el cambio más grande; validarlo localmente contra Gemini antes de tocar el VPS. **Dependencia:** necesita la API key del paso 2.
6. Ítems 1, 2, 4, 7 (config de Production, ForwardedHeaders, health, Data Protection). Son chicos y van juntos en un solo commit de "preparación para deploy".
7. Ítem 5 (catálogos idempotentes).
8. `dotnet build` + tests verdes.

**Fase 2 — Preparar el VPS (independiente de la Fase 1, se puede hacer en paralelo)**
9. Hardening base: usuario no-root, SSH por clave, `ufw` (22/80/443), `fail2ban`, `timedatectl set-timezone`.
10. Instalar SQL Server Express, bindearlo a `127.0.0.1`, crear login/usuario/BD con password fuerte.
11. Instalar ASP.NET Core Runtime 10.
12. Instalar Caddy con el `Caddyfile` mínimo (aún sin backend arriba, solo para validar que emite el certificado). **Dependencia:** paso 3 (DNS resuelto).
13. Crear el usuario `carewell`, el árbol de carpetas y `/etc/carewell/carewell.env` con los secretos **rotados**.
14. Subir `firebase-sa.json` con permisos correctos (sección E).

**Fase 3 — Primer deploy**
15. `dotnet publish` + `rsync` a `/var/www/carewell/api/`. **Dependencia:** Fase 1 completa.
16. Generar y correr el `efbundle`. Luego el script de catálogos. **Dependencia:** paso 10.
17. Instalar y arrancar la unidad de systemd. `journalctl -u carewell-api -f` para ver el arranque.
18. Verificar en este orden: `/health` desde el VPS por `curl http://127.0.0.1:5000/health` → luego `https://api.tudominio.com/health` desde afuera → login real desde la app → **registro con foto de DNI** (valida IA externa + `client_max_body_size`) → **notificación push de emergencia** (valida Firebase) → **reset de contraseña** (valida SMTP saliente; confirmar que DonWeb no bloquea el puerto 2525 de salida).

**Fase 4 — Endurecimiento post-deploy**
19. Ítems 8 y 9 (rate limiting, alerta de push no configurado) — deployar apenas el flujo básico esté verde.
20. Backup automático de la base: `BACKUP DATABASE` diario por cron + copia fuera del VPS. Esto es lo primero que se va a extrañar si algo sale mal.
21. Ítem 11 antes de generar el APK de release.
22. Ítems 10, 12, 13 como deuda técnica planificada.

**Dependencias críticas a no invertir:**
- DNS resuelto → antes de arrancar Caddy (si no, no hay certificado).
- Rotación de secretos → antes de escribir `carewell.env` (si no, se escriben los viejos y hay que rehacerlo).
- Migraciones + catálogos → antes del primer `systemctl start` (si no, la API arranca y falla en cada request).
- API key de Gemini validada a mano → antes de refactorizar `CareWell.DocumentIntelligence` (si no, se podría reescribir para un proveedor que no sirve para el OCR).
