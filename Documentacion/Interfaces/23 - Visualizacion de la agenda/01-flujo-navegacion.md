# US-23 — Flujo de navegación: Visualización de la agenda

## Entrada
- Tap en tile "Mi calendario" del home (US-05)

## Estados de la pantalla
1. **Con datos** (`01-agenda-lista.html`): lista de eventos agrupados por fecha
2. **Vacío** (`02-agenda-vacia.html`): sin eventos programados

## Salidas
| Acción                          | Destino                            |
|---------------------------------|------------------------------------|
| ARROW_BACK                      | Home (US-05)                       |
| Tap FAB ADD                     | US-24 Nuevo evento                 |
| Tap ADD en AppBar               | US-24 Nuevo evento                 |
| Tap tarjeta de evento (futuro)  | US-25 Editar evento (pre-cargado)  |
| Tap tarjeta de evento (pasado)  | US-25 Editar evento (readonly)     |
| Tap "Crear evento" (vacío)      | US-24 Nuevo evento                 |

## Reglas de negocio relevantes
- Los eventos se listan en orden cronológico ascendente.
- Se agrupan por fecha: "HOY", "MAÑANA", luego por día de la semana.
- Eventos cuya fecha y hora ya pasaron se muestran con opacity 0.5 + LOCK icon.
- Eventos pasados son readonly: al tocarlos se navega a US-25 en modo vencido.
- El FAB y el botón ADD del AppBar solo son visibles para usuarios con permiso "Gestionar agenda".
- El chip de contexto muestra la persona a cargo seleccionada actualmente.
