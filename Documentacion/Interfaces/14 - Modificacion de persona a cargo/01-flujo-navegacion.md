# US-14 Modificacion de datos de persona a cargo — Flujo de navegacion

> Mapa de navegacion del flujo de edicion de datos de una persona a cargo.
> Ruta sugerida en `go_router`: `/dependents/:id` (pantalla de detalle/perfil).

---

## 1. Vista general (happy path + ramas)

```
   US-13 (listado) ──► tap en tarjeta
                                │
                                ▼
              ┌─────────────────────────────────────┐
              │   PERFIL PERSONA — LECTURA  [01]     │
              │  AppBar: [←] Alicia Rodriguez [...]  │
              │                                     │
              │  [Avatar A]  Alicia Rodriguez        │
              │              [Persona a cargo]       │
              │                                     │
              │  [PERSON] Nombre completo     [EDIT] │
              │           Alicia Rodriguez          │
              │  [BADGE]  DNI                        │
              │           23.456.789  (sin EDIT)    │
              │  [CALENDAR] Fecha de nac.            │
              │           15/03/1942  (sin EDIT)    │
              │  [EMAIL]  Email                [EDIT]│
              │           alicia@ejemplo.com        │
              └──────────┬──────────────────────────┘
                         │
         ┌───────────────┼────────────────────┐
         │ tap EDIT      │                    │ tap MORE_VERT
         │ (Nombre/Email)│                    ▼
         ▼               │            Menu contextual
  ┌─────────────────┐    │            → "Eliminar persona" ──► US-15
  │  CAMPO EN       │    │
  │  EDICION  [02]  │    │ tap ARROW_BACK
  │  Input inline   │    │
  │  CHECK / CLOSE  │    ▼
  └────────┬────────┘  US-13 (listado)
           │
     ┌─────┴──────┐
     │ tap CHECK  │ tap CLOSE
     │ (guardar)  │ (cancelar)
     ▼            ▼
  ┌──────────────────────────────┐
  │  GUARDADO EXITOSO  [03]      │
  │  Vista lectura normal        │
  │  + Snackbar "Datos de        │
  │    Alicia actualizados"      │
  └──────────────────────────────┘
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| US-13 listado | Perfil lectura [01] | tap en tarjeta | push, slide-right + fade 250 ms |
| Perfil [01] | Campo edicion [02] | tap EDIT en fila | in-place, expansion de fila 200 ms |
| Campo edicion [02] | Guardado [03] | tap CHECK (valor valido) | in-place collapse + snackbar slide-up |
| Campo edicion [02] | Perfil [01] | tap CLOSE | in-place collapse, restaura valor, 150 ms |
| Perfil [01]/[02] | US-13 listado | tap ARROW_BACK | pop, slide-left + fade 250 ms |
| Perfil [01] | US-15 | tap MORE_VERT → Eliminar | dialog modal sobre pantalla actual |

---

## 3. Reglas de gobierno del flujo

- **Solo Responsable con permiso de edicion puede ver los botones EDIT.** Un Cuidador
  que accede al perfil de la persona lo ve en modo solo lectura: sin botones EDIT y sin
  MORE_VERT (o con MORE_VERT sin opcion de eliminar).

- **Un campo activo a la vez.** Si hay un campo en edicion y el usuario toca otro lapiz,
  el campo activo se cierra sin guardar. No hay dialogo de confirmacion: el cambio parcial
  se descarta silenciosamente.

- **DNI y Fecha de nacimiento no son editables.** Se muestran sin boton EDIT. Si el
  usuario necesita corregirlos, debe contactar al soporte o (futuro) usar un flujo
  dedicado de correccion con validacion adicional.

- **Snackbar con nombre.** "Datos de Alicia actualizados" (no generico). Dura 3 s y se
  cierra automaticamente. No requiere accion del usuario.

- **Back con campo activo:** se descarta el campo sin guardar y se navega atras.
  Sin dialogo de confirmacion (accion de bajo impacto).

---

## 4. Relacion con otras US

| US relacionada | Relacion |
|---|---|
| US-13 Listado de personas a cargo | Origen del flujo |
| US-15 Eliminacion de persona a cargo | Flujo secundario, accedido via MORE_VERT |
