/// Catálogos de las alertas/observaciones de bienestar (US-36).
///
/// Espejan 1:1 las constantes del backend
/// (`CareWell.Global/Constantes/Salud/*`). Se usan strings planos en lugar de
/// enums porque el backend envía strings libres: un enum obligaría a un parseo
/// con fallback frágil ante valores nuevos.
abstract final class TiposAlertaBienestar {
  static const String animoBajoSostenido = 'animo_bajo_sostenido';
  static const String deterioroAnimo = 'deterioro_animo';
  static const String abandonoHabito = 'abandono_habito';
  static const String caidaCumplimiento = 'caida_cumplimiento';
}

abstract final class SeveridadesAlertaBienestar {
  static const String alta = 'alta';
  static const String media = 'media';
  static const String baja = 'baja';
}

abstract final class CategoriasAlertaBienestar {
  static const String animo = 'animo';
  static const String habito = 'habito';
}
