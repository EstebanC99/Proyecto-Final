# Pendientes a realizar
## Prioritarios
- Desarrollar backend del móduglo de ***Cambiar contraseña***.
- (*done*) ~~Agregar información de ***Términos y condiciones*** reales pactadas en el doc del proyecto.~~
- Reordenar archivos ***.md*** y ***README***.

## Deseables
- Funcionalidad de exportar la ficha de salud como PDF.
- Agregar un subfiltro dentro de **Linea de Tiempo** por **Tipo de Evento**.
- Anexar funcionalidad de utilidad como *"Preguntas frecuentes"*.
- Auditar los 35 usos de `.when(` por el reintento automático de Riverpod 3 (un provider que falló se muestra como "cargando"). Detalle en `Specs/riverpod3-asyncvalue-error-durante-reintento.md`.
- Corregir el desborde de la tarjeta de usuario de **Configuración** (`SettingsUserCard`) con escalas tipográficas altas: el pill *"Ver perfil"* no es flexible y aplasta el nombre. Caso saltado en `test/presentation/screens/perfil_config_layout_robustez_test.dart`.


# Bugs a corregir
## Críticos
- (*done*) ~~Al eliminar un registro de **Evento de Salud** se rompe el AppBar y no se puede volver atrás, provocando el cierre de la app. *Investigar si pasa en cada uno de los "Eliminar".*~~ -> Se volvía con `context.go()`, que reemplaza el stack completo y borra la historia (Home incluido). Se agregó `context.volverA()` (`config/routers/app_navigation.dart`) y se corrigieron los dos casos rotos (eliminar evento de salud y éxito de *Cambiar contraseña*), los cinco *fallbacks* latentes (personas a cargo y equipo) y la navegación de **Emergencia**, que ahora usa `pushReplacement`. El resto de los "Eliminar" ya volvían con `pop` y estaban sanos.
- No se puede eliminar una serie a futuro ya iniciada. La idea es poder ponerle una **Fecha de Fin** por si queres cancelar la serie futura.
- Error inesperado al intentar registrar un **Evento de agenda** con repetición.
- (*done*) ~~No esta llegando la notificación de **Emergencia** a los dispositivos. *Revisar el google-services.json en el server.*~~ -> El error era debido a la ausenscia del archivo ***google-services.json*** en la ruta ***care_well_app/Android/app/***
