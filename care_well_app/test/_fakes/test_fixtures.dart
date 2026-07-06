/// Fixtures compartidos entre tests.
///
/// Centraliza la construcción de entidades catálogo y comunes para evitar
/// duplicación en los archivos de test y facilitar el mantenimiento.
library;

import 'package:care_well_app/domain/entities/entities.dart';

// ─── Catálogos de estados ─────────────────────────────────────────────────────

final estadoUsuarioActivo = EstadoUsuario(
  id: EstadosUsuarioConst.activo,
  descripcion: 'Activo',
);

final estadoUsuarioSuspendido = EstadoUsuario(
  id: EstadosUsuarioConst.suspendido,
  descripcion: 'Suspendido',
);

final estadoUsuarioEliminado = EstadoUsuario(
  id: EstadosUsuarioConst.eliminado,
  descripcion: 'Eliminado',
);

// ─── Catálogos de roles ───────────────────────────────────────────────────────

final rolCuidadoResponsable = RolCuidado(
  id: RolesCuidadoConst.responsable,
  descripcion: 'Responsable',
);

final rolCuidadoCuidador = RolCuidado(
  id: RolesCuidadoConst.cuidador,
  descripcion: 'Cuidador',
);

// ─── Catálogos de estado de asignación ───────────────────────────────────────

final estadoAsignacionActiva = EstadoAsignacionCuidado(
  id: EstadosAsignacionConst.activa,
  descripcion: 'Activa',
);

final estadoAsignacionInactiva = EstadoAsignacionCuidado(
  id: EstadosAsignacionConst.inactiva,
  descripcion: 'Inactiva',
);

final estadoAsignacionPendiente = EstadoAsignacionCuidado(
  id: EstadosAsignacionConst.pendiente,
  descripcion: 'Pendiente',
);

// ─── Tipos de evento de agenda ────────────────────────────────────────────────

final tipoEventoCitaMedica = TipoEvento(
  id: TiposEventoAgendaConst.citaMedica,
  descripcion: 'Cita médica',
);

final tipoEventoMedicacion = TipoEvento(
  id: TiposEventoAgendaConst.medicacion,
  descripcion: 'Medicación',
);

final tipoEventoControl = TipoEvento(
  id: TiposEventoAgendaConst.control,
  descripcion: 'Control',
);

final tipoEventoOtro = TipoEvento(
  id: TiposEventoAgendaConst.otro,
  descripcion: 'Otro',
);

// ─── Tipos de evento de salud ─────────────────────────────────────────────────

final tipoEventoSaludCitaMedica = TipoEventoSalud(
  id: TiposEventoAgendaConst.citaMedica,
  descripcion: 'Cita médica',
);

final tipoEventoSaludSintoma = TipoEventoSalud(
  id: TiposEventoAgendaConst.sintoma,
  descripcion: 'Síntoma',
);

final tipoEventoSaludVacuna = TipoEventoSalud(
  id: TiposEventoAgendaConst.vacuna,
  descripcion: 'Vacuna',
);

// ─── Referencias embebidas (EntidadBasica) ────────────────────────────────────

final refPersonaAlicia = EntidadBasica(id: 2, descripcion: 'Alicia Rodríguez');
final refPersonaMaria = EntidadBasica(id: 1, descripcion: 'María García');

// ─── Tipos de hábito ──────────────────────────────────────────────────────────

final tipoHabitoActividadFisica = TipoHabitoVida(
  id: TiposHabitoConst.actividadFisica,
  descripcion: 'Actividad física',
);

final tipoHabitoAlimentacion = TipoHabitoVida(
  id: TiposHabitoConst.alimentacion,
  descripcion: 'Alimentación',
);

// ─── Estados de ánimo ─────────────────────────────────────────────────────────

final estadoAnimoMuyBien = EstadoAnimo(
  id: EstadosAnimoConst.muyBien,
  descripcion: 'Muy bien',
);

final estadoAnimoBien = EstadoAnimo(
  id: EstadosAnimoConst.bien,
  descripcion: 'Bien',
);

final estadoAnimoRegular = EstadoAnimo(
  id: EstadosAnimoConst.regular,
  descripcion: 'Regular',
);

final estadoAnimoMal = EstadoAnimo(
  id: EstadosAnimoConst.mal,
  descripcion: 'Mal',
);

final estadoAnimoMuyMal = EstadoAnimo(
  id: EstadosAnimoConst.muyMal,
  descripcion: 'Muy mal',
);
