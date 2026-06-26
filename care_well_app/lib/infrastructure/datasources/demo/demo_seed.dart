import '../../../domain/entities/entities.dart';

/// Datos semilla en memoria para los datasources de demo.
///
/// Cada datasource demo tiene sus propios datos estáticos independientes.
/// Esta clase centraliza los valores de IDs y objetos reutilizables para
/// facilitar la lectura del código, pero NO garantiza consistencia
/// referencial entre módulos: cada datasource es independiente.
///
/// Esquema de rangos de IDs:
/// Personas: 1–99 | Usuarios: 101–199 | Permisos: 301–399
/// Asignaciones: 401–499 | Fichas salud: 501–599 | Configuraciones: 601–699
/// Eventos agenda: 701–799 | Recordatorios: 801–899 | Hábitos: 901–999
/// Recomendaciones: 1001–1099 | Eventos salud: 1101–1199
/// Estados ánimo: 1201–1299 | Notas evento: 1301–1399 | Aceptaciones: 1401–1499
class DemoSeed {
  DemoSeed._();

  // ─── IDs fijos (representan instancias persistentes en la demo) ──────────────

  static const int usuarioMariaId = 101;
  static const int personaMariaId = 1;

  /// Persona a cargo de María: Alicia Rodríguez, 82 años.
  static const int personaAliciaId = 2;

  /// Carlos Pérez — colaborador Responsable.
  static const int personaCarlosId = 3;

  /// Laura Méndez — colaboradora Cuidadora.
  static const int personaLauraId = 4;

  /// Roberto Sánchez — persona sin credenciales (caso de prueba US-04).
  /// Email de prueba para US-04: roberto.sanchez@example.com
  static const int personaRobertoId = 5;

  static const int asignacionCarlosId = 401;
  static const int asignacionLauraId = 402;

  /// María como Responsable de Alicia — asignación del usuario demo principal.
  /// Email de prueba para US-20 (agregar cuidador): usar cualquier email no registrado.
  static const int asignacionMariaId = 403;

  static const int fichaSaludAliciaId = 501;

  static const int configuracionMariaId = 601;

  // ─── Catálogos de uso frecuente ──────────────────────────────────────────────

  static final EstadoUsuario estadoActivo = EstadoUsuario(
    id: EstadosUsuarioConst.activo,
    descripcion: 'Activo',
  );

  static final EstadoUsuario estadoSuspendido = EstadoUsuario(
    id: EstadosUsuarioConst.suspendido,
    descripcion: 'Suspendido',
  );

  static final EstadoUsuario estadoEliminado = EstadoUsuario(
    id: EstadosUsuarioConst.eliminado,
    descripcion: 'Eliminado',
  );

  static final RolCuidado rolCuidadoResponsable = RolCuidado(
    id: RolesCuidadoConst.responsable,
    descripcion: 'Responsable',
  );

  static final RolCuidado rolCuidadoCuidador = RolCuidado(
    id: RolesCuidadoConst.cuidador,
    descripcion: 'Cuidador',
  );

  static final EstadoAsignacionCuidado estadoAsignacionActiva =
      EstadoAsignacionCuidado(
        id: EstadosAsignacionConst.activa,
        descripcion: 'Activa',
      );

  // ─── Personas ────────────────────────────────────────────────────────────────

  static final Persona personaMaria = Persona(
    id: personaMariaId,
    nombre: 'María',
    apellido: 'García',
    documento: '28456789',
    fechaNacimiento: DateTime(1985, 3, 14),
    email: 'maria.garcia@example.com',
    telefono: '+54 9 11 1234-5678',
  );

  static final Persona personaAlicia = Persona(
    id: personaAliciaId,
    nombre: 'Alicia',
    apellido: 'Rodríguez',
    documento: '5234100',
    fechaNacimiento: DateTime(1943, 7, 22),
    email: null,
  );

  static final Persona personaCarlos = Persona(
    id: personaCarlosId,
    nombre: 'Carlos',
    apellido: 'Pérez',
    documento: '22345678',
    fechaNacimiento: DateTime(1978, 11, 5),
    email: 'carlos.perez@example.com',
  );

  static final Persona personaLaura = Persona(
    id: personaLauraId,
    nombre: 'Laura',
    apellido: 'Méndez',
    documento: '31987654',
    fechaNacimiento: DateTime(1991, 4, 20),
    email: 'laura.mendez@example.com',
  );

  /// Persona sin credenciales de acceso — caso de prueba para US-04.
  /// Para probar "Crear credenciales", usar: roberto.sanchez@example.com
  static final Persona personaRoberto = Persona(
    id: personaRobertoId,
    nombre: 'Roberto',
    apellido: 'Sánchez',
    documento: '19876543',
    fechaNacimiento: DateTime(1970, 8, 15),
    email: 'roberto.sanchez@example.com',
  );

  // ─── Usuario ─────────────────────────────────────────────────────────────────

  static final Usuario usuarioMaria = Usuario(
    id: usuarioMariaId,
    persona: personaMaria,
    // En demo la "contraseña" es texto plano para facilitar el login de prueba.
    contrasena: '12345678',
    estado: estadoActivo,
  );

  // ─── Configuración ───────────────────────────────────────────────────────────

  static final Configuracion configuracionMaria = Configuracion(
    id: configuracionMariaId,
    usuario: usuarioMaria,
    notificacionesHabilitadas: true,
    idioma: 'es',
  );

  // ─── Roles y permisos ────────────────────────────────────────────────────────

  static final List<PermisoCuidado> permisosResponsable = [
    PermisoCuidado(
      id: PermisosCuidadoConst.verFichaSalud,
      descripcion: 'Ver ficha de salud',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.editarFichaSalud,
      descripcion: 'Editar ficha de salud',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.gestionarAgenda,
      descripcion: 'Gestionar agenda',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.registrarEventosSalud,
      descripcion: 'Registrar eventos de salud',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.registrarHabitos,
      descripcion: 'Registrar hábitos de vida',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.activarEmergencia,
      descripcion: 'Activar emergencia',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.administrarEquipo,
      descripcion: 'Administrar equipo de cuidado',
    ),
  ];

  static final List<PermisoCuidado> permisosCuidador = [
    PermisoCuidado(
      id: PermisosCuidadoConst.verFichaSalud,
      descripcion: 'Ver ficha de salud',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.gestionarAgenda,
      descripcion: 'Gestionar agenda',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.registrarEventosSalud,
      descripcion: 'Registrar eventos de salud',
    ),
    PermisoCuidado(
      id: PermisosCuidadoConst.activarEmergencia,
      descripcion: 'Activar emergencia',
    ),
  ];

  // ─── Asignaciones de cuidado ─────────────────────────────────────────────────

  static final AsignacionCuidado asignacionCarlos = AsignacionCuidado(
    id: asignacionCarlosId,
    personaCuidada: personaAlicia,
    colaborador: personaCarlos,
    rol: rolCuidadoResponsable,
    estado: estadoAsignacionActiva,
    fechaAlta: DateTime(2024, 1, 10),
    permisos: permisosResponsable,
  );

  static final AsignacionCuidado asignacionLaura = AsignacionCuidado(
    id: asignacionLauraId,
    personaCuidada: personaAlicia,
    colaborador: personaLaura,
    rol: rolCuidadoCuidador,
    estado: estadoAsignacionActiva,
    fechaAlta: DateTime(2024, 3, 5),
    permisos: permisosCuidador,
  );

  /// Asignación de María como Responsable de Alicia.
  /// Usada para que el usuario demo vea a Alicia en su lista de personas a cargo
  /// y pueda gestionar el equipo de cuidado (US-12 a US-22).
  static final AsignacionCuidado asignacionMaria = AsignacionCuidado(
    id: asignacionMariaId,
    personaCuidada: personaAlicia,
    colaborador: personaMaria,
    rol: rolCuidadoResponsable,
    estado: estadoAsignacionActiva,
    fechaAlta: DateTime(2024, 1, 8),
    permisos: permisosResponsable,
  );

  // ─── Eventos de agenda ───────────────────────────────────────────────────────

  static final List<EventoAgenda> eventosAgenda = [
    // Evento futuro (mañana) con recordatorio activo — caso principal US-23/US-27.
    EventoAgenda(
      id: 701,
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Consulta cardiológica',
      descripcion: 'Control de presión arterial y electrocardiograma.',
      tipo: TipoEventoAgenda(
        id: TiposEventoAgendaConst.citaMedica,
        descripcion: 'Cita médica',
      ),
      fechaHoraInicio: DateTime(2026, 6, 10, 10, 0),
      fechaHoraFin: DateTime(2026, 6, 10, 11, 0),
    ),
    // Evento futuro (próximo) con recordatorio activo — toma de medicación.
    EventoAgenda(
      id: 702,
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Toma de medicación matutina',
      descripcion: 'Atenolol 25 mg + Enalapril 10 mg.',
      tipo: TipoEventoAgenda(
        id: TiposEventoAgendaConst.medicacion,
        descripcion: 'Medicación',
      ),
      fechaHoraInicio: DateTime(2026, 6, 7, 8, 0),
    ),
    // Evento futuro — fisioterapia.
    EventoAgenda(
      id: 703,
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Fisioterapia semanal',
      descripcion: 'Sesión de rehabilitación motriz.',
      tipo: TipoEventoAgenda(
        id: TiposEventoAgendaConst.rehabilitacion,
        descripcion: 'Rehabilitación',
      ),
      fechaHoraInicio: DateTime(2026, 6, 12, 14, 30),
      fechaHoraFin: DateTime(2026, 6, 12, 15, 30),
    ),
    // Evento vencido (hace 2 días) — para demostrar estado readonly (US-25).
    EventoAgenda(
      id: 704,
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Control de glucemia',
      descripcion: 'Medición de glucemia en ayunas.',
      tipo: TipoEventoAgenda(
        id: TiposEventoAgendaConst.control,
        descripcion: 'Control',
      ),
      fechaHoraInicio: DateTime(2026, 6, 4, 9, 0),
    ),
    // Evento vencido (ayer) — segundo caso de evento pasado.
    EventoAgenda(
      id: 705,
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Medicación vespertina',
      descripcion: 'Metformina 500 mg con la cena.',
      tipo: TipoEventoAgenda(
        id: TiposEventoAgendaConst.medicacion,
        descripcion: 'Medicación',
      ),
      fechaHoraInicio: DateTime(2026, 6, 5, 20, 0),
    ),
  ];

  // ─── Recordatorios de agenda ─────────────────────────────────────────────────

  /// Recordatorios iniciales para los eventos futuros de demostración.
  static final List<Recordatorio> recordatoriosAgenda = [
    Recordatorio(
      id: 801,
      eventoAgenda: eventosAgenda[0], // 701 — Consulta cardiológica
      fechaHoraEnvio: DateTime(2026, 6, 10, 10, 0),
    ),
    Recordatorio(
      id: 802,
      eventoAgenda: eventosAgenda[1], // 702 — Toma de medicación matutina
      fechaHoraEnvio: DateTime(2026, 6, 7, 8, 0),
    ),
  ];

  // ─── Ficha de salud ──────────────────────────────────────────────────────────

  static final FichaSalud fichaSaludAlicia = FichaSalud(
    id: fichaSaludAliciaId,
    persona: personaAlicia,
    antecedentes:
        'Hipertensión arterial (diagnosticada 2010). '
        'Diabetes tipo 2 (diagnosticada 2015). '
        'Artrosis de rodilla bilateral.',
    estudios:
        'ECG (abril 2026): ritmo sinusal normal. '
        'Laboratorio (mayo 2026): glucemia 130 mg/dL, HbA1c 7.2%.',
  );

  // ─── Hábitos de vida ─────────────────────────────────────────────────────────

  /// Hábitos propios de María (usuario demo, contexto "Yo").
  static final List<HabitoDeVida> habitosMaria = [
    HabitoDeVida(
      id: 901,
      persona: personaMaria,
      tipo: TipoHabito(
        id: TiposHabitoConst.actividadFisica,
        descripcion: 'Actividad física',
      ),
      descripcion:
          'Caminata de 30 minutos antes del trabajo, cinco días a la semana.',
    ),
    HabitoDeVida(
      id: 902,
      persona: personaMaria,
      tipo: TipoHabito(
        id: TiposHabitoConst.hidratacion,
        descripcion: 'Hidratación',
      ),
      descripcion: 'Dos litros de agua por día. Recuerda beber entre comidas.',
    ),
  ];

  static final List<HabitoDeVida> habitosAlicia = [
    HabitoDeVida(
      id: 903,
      persona: personaAlicia,
      tipo: TipoHabito(
        id: TiposHabitoConst.actividadFisica,
        descripcion: 'Actividad física',
      ),
      descripcion:
          'Caminata de 20 minutos por el parque, tres veces por semana.',
    ),
    HabitoDeVida(
      id: 904,
      persona: personaAlicia,
      tipo: TipoHabito(
        id: TiposHabitoConst.alimentacion,
        descripcion: 'Alimentación',
      ),
      descripcion: 'Dieta baja en sodio y azúcares simples. Sin sal de mesa.',
    ),
    HabitoDeVida(
      id: 905,
      persona: personaAlicia,
      tipo: TipoHabito(
        id: TiposHabitoConst.hidratacion,
        descripcion: 'Hidratación',
      ),
      descripcion: 'Ingesta de al menos 1,5 litros de agua por día.',
    ),
  ];

  // ─── Recomendaciones médicas ─────────────────────────────────────────────────

  static final List<RecomendacionMedica> recomendacionesAlicia = [
    RecomendacionMedica(
      id: 1001,
      persona: personaAlicia,
      descripcion:
          'Controlar la presión arterial dos veces al día. Registrar valores.',
      fecha: DateTime(2026, 5, 15),
      profesional: 'Dr. Hernández (Cardiología)',
    ),
    RecomendacionMedica(
      id: 1002,
      persona: personaAlicia,
      descripcion:
          'Evitar esfuerzos físicos prolongados. Descanso obligatorio a las 16 hs.',
      fecha: DateTime(2026, 4, 10),
      profesional: 'Dra. Romero (Clínica médica)',
    ),
  ];

  // ─── Eventos de salud ────────────────────────────────────────────────────────

  /// Eventos de salud propios de María (usuario demo, contexto "Yo").
  static final List<EventoDeSalud> eventosSaludMaria = [
    EventoDeSalud(
      id: 1101,
      persona: personaMaria,
      tipo: TipoEventoSalud(
        id: TiposEventoSaludConst.citaMedica,
        descripcion: 'Cita médica',
      ),
      fecha: DateTime(2026, 5, 20),
      descripcion: 'Control anual con médico clínico — Dr. Alejandro Torres.',
    ),
  ];

  static final EventoDeSalud eventoSaludMareos = EventoDeSalud(
    id: 1102,
    persona: personaAlicia,
    tipo: TipoEventoSalud(
      id: TiposEventoSaludConst.sintoma,
      descripcion: 'Síntoma',
    ),
    fecha: DateTime(2026, 5, 28),
    descripcion: 'Episodio de mareos al levantarse. Duración aprox. 5 minutos.',
  );

  static final EventoDeSalud eventoSaludControlCardiologico = EventoDeSalud(
    id: 1103,
    persona: personaAlicia,
    tipo: TipoEventoSalud(
      id: TiposEventoSaludConst.citaMedica,
      descripcion: 'Cita médica',
    ),
    fecha: DateTime(2026, 6, 2),
    descripcion: 'Control cardiológico — Dr. Martín Sosa · Hospital Italiano.',
  );

  static final List<EventoDeSalud> eventosSaludAlicia = [
    eventoSaludControlCardiologico,
    eventoSaludMareos,
    EventoDeSalud(
      id: 1104,
      persona: personaAlicia,
      tipo: TipoEventoSalud(
        id: TiposEventoSaludConst.vacuna,
        descripcion: 'Vacuna',
      ),
      fecha: DateTime(2026, 4, 3),
      descripcion: 'Vacuna antigripal anual.',
    ),
  ];

  // ─── Notas de eventos de salud ───────────────────────────────────────────────

  static final List<NotaEvento> notasEvento = [
    NotaEvento(
      id: 1301,
      eventoSaludId: 1103,
      autor: personaMaria,
      fechaHora: DateTime(2026, 6, 2, 14, 32),
      contenido:
          'El médico indicó repetir análisis en 3 meses. Solicitar turno a fin de mes.',
    ),
    NotaEvento(
      id: 1302,
      eventoSaludId: 1103,
      autor: personaLaura,
      fechaHora: DateTime(2026, 6, 3, 9, 15),
      contenido: 'Acordado con Alicia hacer los análisis en Fleni.',
    ),
    NotaEvento(
      id: 1303,
      eventoSaludId: 1102,
      autor: personaMaria,
      fechaHora: DateTime(2026, 5, 28, 11, 0),
      contenido:
          'Presión se normalizó a los 15 minutos. Se informó al cardiólogo por WhatsApp.',
    ),
    // Nota migrada desde el campo notas del evento 1102.
    NotaEvento(
      id: 1304,
      eventoSaludId: 1102,
      autor: personaMaria,
      fechaHora: DateTime(2026, 5, 28, 10, 5),
      contenido: 'Presión al momento: 90/60. Se la acostó y pasó solo.',
    ),
    // Nota migrada desde el campo notas del evento 1101 (María).
    NotaEvento(
      id: 1305,
      eventoSaludId: 1101,
      autor: personaMaria,
      fechaHora: DateTime(2026, 5, 20, 12, 0),
      contenido: 'Todo en orden. Indicó análisis de laboratorio en 6 meses.',
    ),
  ];

  // ─── Estados de ánimo ────────────────────────────────────────────────────────

  static final List<EstadoDeAnimo> estadosAnimoAlicia = [
    EstadoDeAnimo(
      id: 1201,
      persona: personaAlicia,
      fecha: DateTime(2026, 6, 4),
      estado: EstadoAnimo(id: EstadosAnimoConst.bien, descripcion: 'Bien'),
      observaciones: 'Estuvo animada en el desayuno.',
    ),
    EstadoDeAnimo(
      id: 1202,
      persona: personaAlicia,
      eventoDeSalud: eventoSaludMareos,
      fecha: DateTime(2026, 5, 28),
      estado: EstadoAnimo(id: EstadosAnimoConst.mal, descripcion: 'Mal'),
      observaciones: 'Preocupada tras el episodio de mareos.',
    ),
  ];

  // ─── Aceptaciones de términos ────────────────────────────────────────────────

  static final List<AceptacionTerminos> aceptacionesMaria = [
    AceptacionTerminos(
      id: 1401,
      usuario: usuarioMaria,
      version: '1.0',
      fechaAceptacion: DateTime(2024, 1, 8),
    ),
  ];
}
