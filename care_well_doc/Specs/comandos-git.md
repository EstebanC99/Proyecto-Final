# Comandos Git — Rama para feature grande de cambios visuales (front)

> Guía para llevar adelante una feature grande de rediseño visual en `care_well_app/` sin
> afectar la rama `main`.

## 1. Crear la rama desde `main`
```bash
git checkout main
git pull origin main
git checkout -b feature/rediseno-visual-ui
```
Ajustar el nombre de la rama según la feature. Conventional commits sugiere el prefijo
`feature/...` para cambios grandes.

## 2. Trabajar en la rama
- Todos los cambios de UI (temas, widgets, pantallas — trabajo de `disenador-ui` + `dev-flutter`)
  se hacen en esta rama.
- Commits chicos y frecuentes, en español, estilo conventional commits (`feat:`, `refactor:`,
  `style:`...) como indica el CLAUDE.md del proyecto.
- `main` no se toca en ningún momento mientras dure la feature.

## 3. Pushear la rama a GitHub (backup + visibilidad)
```bash
git push -u origin feature/rediseno-visual-ui
```
A partir de acá, cada `git push` sin flags ya apunta a esa rama.

## 4. Mantenerla al día con `main`
Como es una feature grande y probablemente tarde en cerrarse, conviene traer los cambios de
`main` cada tanto para evitar un merge gigante al final:
```bash
git checkout main
git pull origin main
git checkout feature/rediseno-visual-ui
git merge main
```
(o `git rebase main` si se prefiere historia lineal — con conventional commits + PR, el merge
suele ser más simple de revisar).

## 5. Cerrar la feature
Cuando esté lista:
```bash
git push origin feature/rediseno-visual-ui
```
y abrir un Pull Request `feature/rediseno-visual-ui → main` en GitHub para revisión antes de
mergear.

## Notas
- Si la feature es muy grande, se puede trabajar en varias sub-ramas cortas que mergeen a
  `feature/rediseno-visual-ui` en vez de una sola rama larga — así los diffs de revisión son
  más chicos.
