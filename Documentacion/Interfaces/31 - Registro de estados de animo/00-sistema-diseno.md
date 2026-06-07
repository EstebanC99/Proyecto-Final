# Sistema de diseño — US-31 Registro de estados de ánimo

## Módulo
Mi salud — color primario `#E11D48`, container `#FFF1F2`.

## Paleta de estados de ánimo

| Nivel | Label     | Color      | Uso                            |
|-------|-----------|------------|--------------------------------|
| 5     | Muy bien  | `#16A34A`  | Verde — estado óptimo          |
| 4     | Bien      | `#65A30D`  | Verde claro — estado positivo  |
| 3     | Regular   | `#CA8A04`  | Ámbar — estado neutro          |
| 2     | Mal       | `#EA580C`  | Naranja — estado negativo      |
| 1     | Muy mal   | `#DC2626`  | Rojo — estado crítico          |

## Tokens compartidos con el sistema global

- **Background app:** `#F6F8F8`
- **Surface card:** `#FFFFFF`
- **Texto primario:** `#16201F`
- **Texto secundario:** `#566060`
- **Texto terciario / metadatos:** `#9AA5A5`
- **Border default:** `#C5CECE`
- **Border light:** `#EDF1F1`

## Componente: Selector de estado (MoodPicker)

- Contenedor horizontal, distribución space-around dentro de una card surface
- Cada opción: círculo 64×64 px, ícono SVG Material 36×36 px centrado, label 11 px debajo
- Estado no seleccionado: fondo `#EDF1F1`, ícono `#9AA5A5`
- Estado seleccionado: fondo del color del nivel (ej. `#F0FDF4` para Bien), borde 3 px sólido en el color del nivel, transform scale 1.1
- Área táctil mínima: 48×48 px (círculo 64 px la supera)

## Componente: MoodBar (gráfico de barras CSS)

- 7 columnas, width 28 px cada una, border-radius 8 px 8 px 0 0
- Altura mapeada al nivel: Muy bien=80 px, Bien=64 px, Regular=48 px, Mal=32 px, Muy mal=16 px
- Color de barra según nivel (paleta de estados de ánimo)
- Label de día 11 px `#566060`, centrado debajo de cada barra

## Tipografía (hereda del sistema global)

- Screen title (AppBar): 18 px / 700
- Section label: 12 px / 700 / uppercase / `#566060`
- Body: 14 px / 400 / `#16201F`
- Caption: 12 px / 400 / `#566060`
- Micro: 11 px / 400 / `#9AA5A5`
