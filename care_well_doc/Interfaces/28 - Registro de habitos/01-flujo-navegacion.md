# US-28 Registro de hábitos de vida — Flujo de navegación

> Ruta go_router sugerida: `/health/habits`
> Pantalla anterior: Hub Mi salud (`/health`)

---

## 1. Vista general

```
  Home ─► /health (Hub Mi salud) ─► /health/habits (Lista de hábitos)
                                         │
                                         ├── tap card ──► /health/habits/:category (detalle + histórico)
                                         │
                                         └── tap FAB ──► /health/habits/new (registrar hábito)
                                                              │
                                                              └── guardar ──► Lista (con snackbar OK)
```

---

## 2. Pantallas del flujo

| ID  | Archivo HTML              | Descripción                                      |
|-----|---------------------------|--------------------------------------------------|
| H00 | 00-mi-salud-hub.html      | Hub del módulo Mi salud (punto de entrada)       |
| H01 | 01-habitos-lista.html     | Lista de categorías con último registro y chips  |
| H02 | 02-registrar-habito.html  | Formulario para registrar nuevo hábito           |

---

## 3. Transiciones

| Origen          | Destino           | Disparador               | Animación                       |
|-----------------|-------------------|--------------------------|---------------------------------|
| Hub Mi salud    | Lista hábitos     | tap tile "Hábitos"       | slide-right + fade 250 ms       |
| Lista hábitos   | Detalle categoría | tap card                 | slide-right + fade 250 ms       |
| Lista hábitos   | Nuevo hábito      | tap FAB                  | slide-up (modal) 300 ms         |
| Nuevo hábito    | Lista hábitos     | guardar exitoso          | pop + snackbar "Hábito guardado"|
| Nuevo hábito    | Lista hábitos     | tap ARROW_BACK           | pop sin snackbar                |
| Cualquiera      | Hub Mi salud      | tap ARROW_BACK           | pop, slide-left                 |

---

## 4. Reglas de gobierno

- La categoría seleccionada en la lista se pre-selecciona al abrir el formulario de nuevo
  hábito desde la card de esa categoría. Si se llega desde el FAB sin contexto, se pre-
  selecciona "Alimentación" como primera categoría.
- La fecha se pre-carga con el día actual; el usuario puede cambiarla.
- La hora es opcional: si no se completa, se registra sin hora.
- El campo descripción es de texto libre dentro de la categoría; no hay validación de formato.
- El botón "Registrar" se habilita cuando la descripción no está vacía.
- Al guardar, la lista se refresca y la card de la categoría correspondiente actualiza el
  chip de frecuencia y el último registro.
