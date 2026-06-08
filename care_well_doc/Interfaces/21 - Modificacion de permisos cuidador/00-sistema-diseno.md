# US-21 — Sistema de diseño

## Paleta de colores
- primary: #1A8C82
- error: #D14343 / fondo: #FBE3E3
- success: #2E9E5B / fondo: #D8F0E1
- bg: #F6F8F8
- surface: #FFFFFF
- textPrimary: #16201F
- textSecondary: #566060
- outline: #C5CECE
- secondaryContainer (cuidador): #FCE2DA
- accentCuidador: #7A2E1A

## Diferenciacion por rol
El badge de Cuidador usa secondaryContainer (#FCE2DA) con texto #7A2E1A (salmon oscuro),
contrastando con el badge de Responsable que usa #C9EDE8 con texto #1A8C82 (teal).
Esta distincion cromatica informa de inmediato el nivel de privilegio del miembro.

## Permisos de cuidador — estado por defecto
Solo 2 de 6 permisos activos al crear la cuenta. El rol Cuidador tiene acceso
restrictivo por diseno: puede ver, pero no puede actuar sobre datos sensibles
sin que el Responsable lo habilite explicitamente.

## Tipografia
- Familia: Segoe UI, Arial, sans-serif
- Titulo AppBar: 16px / 700
- Nombre miembro: 16px / 700
- Badge: 12px / 600
- Email: 13px / regular
- Etiqueta permiso: 15px / 500
- Seccion titulo: 14px / 700
- Boton primario: 16px / 700

## Componentes
- Avatar circular 52px, inicial centrada
- Toggle 40x22px: ON = #1A8C82 (thumb derecha), OFF = #C5CECE (thumb izquierda)
- Fila de permiso: min-height 56px, padding 0 16px
- Boton primario: height 56px, border-radius 16px, posicion fija al fondo
- Snackbar: bg #323232, texto blanco, icono check verde, border-radius 8px

## Viewport
390 x 844 px — Android first
