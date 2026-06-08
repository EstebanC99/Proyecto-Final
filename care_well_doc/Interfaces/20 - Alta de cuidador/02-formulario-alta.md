# US-20 — Pantalla: Formulario de alta de cuidador

## Objetivo
Permitir al responsable agregar un nuevo cuidador al equipo ingresando su email y configurando los permisos iniciales antes de enviar la invitacion.

## Layout (jerarquía de componentes)
```
StatusBar (28px, dark)
AppBar
  ├─ ARROW_BACK 24px
  └─ Título "Agregar cuidador" (16px bold, centrado)

Content (scroll, padding 20px 16px)
  ├─ Subtítulo
  │    "El cuidador accederá a las funciones que vos autorices para el cuidado de Alicia Rodríguez."
  │    (14px #566060, margin-bottom 24px)
  │    "Alicia Rodríguez" en bold #16201F
  │
  ├─ Campo "Email del cuidador"
  │    ├─ Label "Email del cuidador" (13px 500 #566060, margin-bottom 6px)
  │    ├─ AppTextField (height 56px, bg #FFF, border 1px #C5CECE, radius 12px)
  │    │    ├─ EMAIL icon 20px (color #566060, a la izquierda)
  │    │    └─ Placeholder "correo@ejemplo.com"
  │    └─ Helper "Debe tener una cuenta en CareWell" (12px #566060, margin-top 6px)
  │
  ├─ SectionTitle "Permisos iniciales" (14px bold, margin-top 28px, margin-bottom 8px)
  │
  ├─ PermissionList (bg #FFF, border-radius 12px, overflow: hidden)
  │    ├─ PermissionRow [ON]  "Ver datos personales"
  │    ├─ PermissionRow [ON]  "Ver agenda"
  │    ├─ PermissionRow [OFF] "Editar agenda"
  │    ├─ PermissionRow [OFF] "Ver historial de salud"
  │    ├─ PermissionRow [OFF] "Enviar alertas de emergencia al equipo"
  │    └─ PermissionRow [OFF] "Gestionar equipo"
  │
  └─ NoteText "Podés ajustar estos permisos en cualquier momento desde Mi equipo."
       (13px #566060, italic, margin 12px 0 32px 0)

PrimaryButton "Agregar cuidador" (fijo al fondo, margin 16px, height 56px)
```

## Diferencia visual clave con US-18
- 4 de 6 permisos estan en OFF (vs 4 en ON en US-18).
- Esto comunica visualmente que el cuidador tiene un perfil de acceso mas restringido.
- La nota bajo la lista refuerza que estos valores son ajustables, reduciendo la presion de decidir bien en este momento.

## Especificacion del campo email
- Height: 56px
- Background: #FFF
- Border: 1px solid #C5CECE (normal), 2px solid #1A8C82 (foco)
- Border-radius: 12px
- Padding: 0 16px
- Gap entre icono y texto: 12px
- Placeholder color: #9AA5A5
- Helper text: font-size 12px, color #566060, margin-top 6px

## Interacciones
- Tap en campo email: teclado aparece, borde cambia a teal.
- Tap en PermissionRow: toggle invierte su estado.
- Tap en "Agregar cuidador": valida email, si OK dispara llamada API.
- Boton deshabilitado visualmente si el campo email esta vacio (opacity 0.5, pointer-events: none).
