# US-22 — Sistema de diseño

## Paleta de colores
- primary: #1A8C82
- error / destructivo: #D14343 / fondo: #FBE3E3
- success: #2E9E5B / fondo: #D8F0E1
- bg: #F6F8F8
- surface: #FFFFFF
- textPrimary: #16201F
- textSecondary: #566060
- outline: #C5CECE
- secondaryContainer (cuidador): #FCE2DA
- accentCuidador: #7A2E1A

## Patron de dialogo M3 (destructivo)
- border-radius: 28px
- padding: 24px
- margen lateral: 24px
- sombra: 0 8px 32px rgba(0,0,0,0.18)
- Icono centrado (PERSON_REMOVE 48px en #D14343) — señal visual de severidad
- Boton destructivo primero (altura 44px, bg #D14343)
- Boton cancelar segundo (altura 44px, borde #C5CECE)
- Orden: accion principal arriba, escape abajo — elimina ambiguedad en contexto de estres

## Scrim
- rgba(0,0,0,0.4) sobre la pantalla de fondo
- La pantalla de fondo reconocible bajo el scrim refuerza el contexto de la accion

## Viewport
390 x 844 px — Android first

## Relacion con US-19 (Baja de responsable)
Mismo patron visual exacto, cambiando:
- Nombre y datos del miembro: Sandra Ruiz (Cuidadora) vs Carlos Perez (Responsable)
- Genero gramatical en el texto del dialog
- Color de avatar y badge: salmon (#FCE2DA/#7A2E1A) vs teal (#C9EDE8/#1A8C82)
