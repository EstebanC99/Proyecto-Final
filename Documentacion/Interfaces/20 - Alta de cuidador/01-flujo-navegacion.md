# US-20 — Flujo de navegación: Alta de cuidador en el equipo

## Entrada
- Desde la pantalla "Mi equipo" al pulsar el FAB o boton "Agregar cuidador".
- go_router: `/care-team/add-caregiver?dependentId=:dependentId`
- Parámetro: `dependentId` (ID de la persona a cargo del equipo activo).

## Flujo principal
```
Mi equipo (lista)
  └─> [Agregar cuidador] ──> 01-formulario-alta.html (pantalla de formulario)
                                    │
                           [Completar email + ajustar permisos]
                                    │
                           [Agregar cuidador]
                                    │
                           Validacion de email (formato)
                                    │
                           Llamada API POST /care-team/members
                                    │
                           Boton en estado loading
                                    │
                           Respuesta 200/201
                                    │
                           02-exito.html (pantalla de exito)
                                    │
                           [Volver al equipo] ──> Mi equipo (lista, con nuevo cuidador)
```

## Flujo alternativo — email invalido
```
[Agregar cuidador] con email mal formado
  └─> Inline error bajo el campo: "Ingresá un email válido"
        (sin llamada a API, validacion en cliente)
```

## Flujo alternativo — email no registrado
```
API devuelve 404 / email no encontrado
  └─> Snackbar: "No encontramos una cuenta con ese email"
        (el campo mantiene el valor, el usuario puede corregir)
```

## Flujo alternativo — miembro ya en el equipo
```
API devuelve 409 / conflicto
  └─> Snackbar: "Esa persona ya es parte del equipo"
```

## Navegacion de salida
- ARROW_BACK → vuelve a "Mi equipo" sin agregar (sin confirmacion, no hay datos sensibles).
- Boton "Volver al equipo" en pantalla de exito → navega a "Mi equipo" (replace, no push).

## Estados de pantalla
| Estado    | Descripcion                                                               |
|-----------|---------------------------------------------------------------------------|
| Vacio     | Campo email vacio, permisos en estado por defecto                         |
| Con email | Campo con valor, permisos ajustables                                      |
| Error     | Inline error en campo o snackbar segun tipo de error                      |
| Cargando  | Boton en loading, campo y toggles deshabilitados                          |
| Exito     | Pantalla de confirmacion dedicada                                         |
