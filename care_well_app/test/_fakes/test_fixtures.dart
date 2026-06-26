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

final tipoEventoAgendaCitaMedica = TipoEventoAgenda(
  id: TiposEventoAgendaConst.citaMedica,
  descripcion: 'Cita médica',
);

final tipoEventoAgendaMedicacion = TipoEventoAgenda(
  id: TiposEventoAgendaConst.medicacion,
  descripcion: 'Medicación',
);

final tipoEventoAgendaControl = TipoEventoAgenda(
  id: TiposEventoAgendaConst.control,
  descripcion: 'Control',
);

final tipoEventoAgendaOtro = TipoEventoAgenda(
  id: TiposEventoAgendaConst.otro,
  descripcion: 'Otro',
);

// ─── Tipos de evento de salud ─────────────────────────────────────────────────

final tipoEventoSaludCitaMedica = TipoEventoSalud(
  id: TiposEventoSaludConst.citaMedica,
  descripcion: 'Cita médica',
);

final tipoEventoSaludSintoma = TipoEventoSalud(
  id: TiposEventoSaludConst.sintoma,
  descripcion: 'Síntoma',
);

final tipoEventoSaludVacuna = TipoEventoSalud(
  id: TiposEventoSaludConst.vacuna,
  descripcion: 'Vacuna',
);

// ─── Tipos de hábito ──────────────────────────────────────────────────────────

final tipoHabitoActividadFisica = TipoHabito(
  id: TiposHabitoConst.actividadFisica,
  descripcion: 'Actividad física',
);

final tipoHabitoAlimentacion = TipoHabito(
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
