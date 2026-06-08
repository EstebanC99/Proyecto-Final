# US-16 — Pantalla: Equipo con miembros (01-equipo.html)

## Objetivo
Mostrar el estado principal de la pantalla Mi equipo cuando existen responsables y/o cuidadores
asignados a la persona bajo cuidado.

## Layout (jerarquía de componentes, top → bottom)

```
StatusBar (28px, dark)
AppBar
  ├── IconButton ARROW_BACK (40px)
  ├── Título "Mi equipo" (18px bold)
  └── IconButton ADD circular (40px, bg primary)
ScrollView (padding 0 16px 88px)  ← padding bottom deja espacio al FAB
  ├── ChipContexto ("Viendo equipo de: Alicia Rodríguez") margin-top 16px
  ├── SectionHeader "RESPONSABLES" margin-top 20px
  ├── MemberCard — Laura García (Vos) [Responsable]
  ├── MemberCard — Martín López [Responsable]
  ├── SectionHeader "CUIDADORES" margin-top 20px
  └── MemberCard — Sandra Ruiz [Cuidadora]
FAB ADD (absolute, bottom 24px, right 16px)
```

## Especificación de cada componente

### AppBar
- Fondo: #FFFFFF (surface), sombra: 0 1px 0 #C5CECE
- Altura: 56px
- Padding horizontal: 4px (los IconButtons tienen su propio padding)
- Botón ADD: círculo 40px, bg #1A8C82, icono ADD blanco 24px, border-radius 50%

### ChipContexto
- Contenedor: inline-flex, align-items center, gap 6px
- bg #C9EDE8, border-radius 12px, padding 8px 16px
- Texto: "Viendo equipo de:" 13px regular #566060 + " Alicia Rodríguez" 13px bold #16201F
- Ancho: fit-content (no ocupa todo el ancho)
- Margin: 16px 0 0 0

### SectionHeader
- Texto: 12px / font-weight 600 / color #566060 / text-transform uppercase / letter-spacing 0.8px
- Margin: 20px 0 8px 0
- Primera aparición: margin-top 20px

### MemberCard
- bg #FFFFFF, border-radius 12px, padding 14px 16px
- Sombra: 0 1px 4px rgba(0,0,0,0.08)
- Margin-bottom: 8px
- Layout: flex row, align-items center, gap 12px
- min-height: 72px (objetivo táctil)
- Cursor: pointer, hover: sombra 0 2px 8px rgba(0,0,0,0.12)

#### Avatar
- 44px x 44px, border-radius 50%
- bg #C9EDE8
- Inicial del nombre: 18px bold #0A3D38, centrada

#### Columna de texto
- flex: 1
- Nombre: 15px bold #16201F
  - Si es el usuario autenticado: nombre + " (Vos)" donde "(Vos)" es 13px regular #566060
- Email: 13px regular #566060, margin-top 2px

#### Badge de rol
- Responsable: bg #C9EDE8, color #0A3D38, texto "Responsable"
- Cuidador: bg #FCE2DA, color #7A2E1A, texto "Cuidador"
- Medidas: 11px / font-weight 600 / border-radius 999px / padding 2px 8px
- Posición: inline junto a CHEVRON_RIGHT en columna derecha

#### Columna derecha
- flex-direction: column, align-items: flex-end, gap 6px
- Badge arriba
- CHEVRON_RIGHT 20px color #9AA5A5 abajo (o centrado si solo hay uno)

### FAB
- 56px x 56px, border-radius 50%
- bg #1A8C82, icono ADD blanco 24px
- Sombra: 0 4px 12px rgba(26,140,130,0.35)
- position: absolute, bottom: 24px, right: 16px
- z-index: 10

## Datos de ejemplo
- Responsable 1: Laura García / lauragarcia@email.com / inicial "L" / (Vos)
- Responsable 2: Martín López / martin.lopez@email.com / inicial "M"
- Cuidadora 1: Sandra Ruiz / sandra.ruiz@email.com / inicial "S"

## Interacciones
- Tap MemberCard → navega a gestión de permisos del miembro (US-18 o US-21 según rol)
- Tap ADD AppBar / FAB → navega a US-17
- Scroll vertical cuando hay muchos miembros (FAB permanece fijo)

## Anotaciones de diseño
1. Equipo contextualizado por persona: el chip permite saber de quién se está viendo el equipo
2. Tap en MemberCard navega a gestión de permisos (US-18 para responsable, US-21 para cuidador)
3. El usuario autenticado se identifica con "(Vos)" para evitar confusión
4. FAB y botón ADD en AppBar ofrecen el mismo destino: redundancia intencional para accesibilidad
5. Sombra sutil en cards: jerarquía visual sin ruido
