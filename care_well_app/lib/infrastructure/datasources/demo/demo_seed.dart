import '../../../domain/entities/entities.dart';

/// Datos semilla en memoria para los datasources de demo.
///
/// Cada datasource demo tiene sus propios datos estáticos independientes.
/// Esta clase centraliza los valores de IDs y objetos reutilizables para
/// facilitar la lectura del código, pero NO garantiza consistencia
/// referencial entre módulos: cada datasource es independiente.
class DemoSeed {
  DemoSeed._();

  // ─── IDs fijos (representan instancias persistentes en la demo) ──────────────

  static const String usuarioMariaId = 'usr_001';
  static const String personaMariaId = 'per_001';

  /// Persona a cargo de María: Alicia Rodríguez, 82 años.
  static const String personaAliciaId = 'per_002';

  /// Carlos Pérez — colaborador Responsable.
  static const String personaCarlosId = 'per_003';

  /// Laura Méndez — colaboradora Cuidadora.
  static const String personaLauraId = 'per_004';

  /// Roberto Sánchez — persona sin credenciales (caso de prueba US-04).
  /// Email de prueba para US-04: roberto.sanchez@example.com
  static const String personaRobertoId = 'per_005';

  static const String rolResponsableId = 'rol_001';
  static const String rolCuidadorId = 'rol_002';

  static const String asignacionCarlosId = 'asi_001';
  static const String asignacionLauraId = 'asi_002';

  /// María como Responsable de Alicia — asignación del usuario demo principal.
  /// Email de prueba para US-20 (agregar cuidador): usar cualquier email no registrado.
  static const String asignacionMariaId = 'asi_003';

  static const String fichaSaludAliciaId = 'fis_001';

  static const String configuracionMariaId = 'cfg_001';

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
    nombreUsuario: 'maria.garcia',
    // En demo la "contraseña" es texto plano para facilitar el login de prueba.
    contrasenaHash: '12345678',
    estado: EstadoUsuario.activo,
  );

  // ─── Configuración ───────────────────────────────────────────────────────────

  static final Configuracion configuracionMaria = Configuracion(
    id: configuracionMariaId,
    usuario: usuarioMaria,
    notificacionesHabilitadas: true,
    idioma: 'es',
  );

  // ─── Roles y permisos ────────────────────────────────────────────────────────

  static final List<Permiso> permisosResponsable = [
    const Permiso(
      id: 'prm_001',
      codigo: CodigoPermiso.verFichaSalud,
      descripcion: 'Ver ficha de salud',
    ),
    const Permiso(
      id: 'prm_002',
      codigo: CodigoPermiso.editarFichaSalud,
      descripcion: 'Editar ficha de salud',
    ),
    const Permiso(
      id: 'prm_003',
      codigo: CodigoPermiso.gestionarAgenda,
      descripcion: 'Gestionar agenda',
    ),
    const Permiso(
      id: 'prm_004',
      codigo: CodigoPermiso.registrarEventosSalud,
      descripcion: 'Registrar eventos de salud',
    ),
    const Permiso(
      id: 'prm_005',
      codigo: CodigoPermiso.registrarHabitos,
      descripcion: 'Registrar hábitos de vida',
    ),
    const Permiso(
      id: 'prm_006',
      codigo: CodigoPermiso.activarEmergencia,
      descripcion: 'Activar emergencia',
    ),
    const Permiso(
      id: 'prm_007',
      codigo: CodigoPermiso.administrarEquipo,
      descripcion: 'Administrar equipo de cuidado',
    ),
  ];

  static final List<Permiso> permisosCuidador = [
    const Permiso(
      id: 'prm_008',
      codigo: CodigoPermiso.verFichaSalud,
      descripcion: 'Ver ficha de salud',
    ),
    const Permiso(
      id: 'prm_009',
      codigo: CodigoPermiso.gestionarAgenda,
      descripcion: 'Gestionar agenda',
    ),
    const Permiso(
      id: 'prm_010',
      codigo: CodigoPermiso.registrarEventosSalud,
      descripcion: 'Registrar eventos de salud',
    ),
    const Permiso(
      id: 'prm_011',
      codigo: CodigoPermiso.activarEmergencia,
      descripcion: 'Activar emergencia',
    ),
  ];

  static final Rol rolResponsable = Rol(
    id: rolResponsableId,
    nombre: RolCuidado.responsable,
  );

  static final Rol rolCuidador = Rol(
    id: rolCuidadorId,
    nombre: RolCuidado.cuidador,
  );

  // ─── Asignaciones de cuidado ─────────────────────────────────────────────────

  static final AsignacionCuidado asignacionCarlos = AsignacionCuidado(
    id: asignacionCarlosId,
    personaCuidada: personaAlicia,
    personaColaborador: personaCarlos,
    rol: rolResponsable,
    estado: EstadoAsignacion.activa,
    fechaAlta: DateTime(2024, 1, 10),
    permisos: permisosResponsable,
  );

  static final AsignacionCuidado asignacionLaura = AsignacionCuidado(
    id: asignacionLauraId,
    personaCuidada: personaAlicia,
    personaColaborador: personaLaura,
    rol: rolCuidador,
    estado: EstadoAsignacion.activa,
    fechaAlta: DateTime(2024, 3, 5),
    permisos: permisosCuidador,
  );

  /// Asignación de María como Responsable de Alicia.
  /// Usada para que el usuario demo vea a Alicia en su lista de personas a cargo
  /// y pueda gestionar el equipo de cuidado (US-12 a US-22).
  static final AsignacionCuidado asignacionMaria = AsignacionCuidado(
    id: asignacionMariaId,
    personaCuidada: personaAlicia,
    personaColaborador: personaMaria,
    rol: rolResponsable,
    estado: EstadoAsignacion.activa,
    fechaAlta: DateTime(2024, 1, 8),
    permisos: permisosResponsable,
  );

  // ─── Eventos de agenda ───────────────────────────────────────────────────────

  static final List<EventoAgenda> eventosAgenda = [
    // Evento futuro (mañana) con recordatorio activo — caso principal US-23/US-27.
    EventoAgenda(
      id: 'evt_001',
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Consulta cardiológica',
      descripcion: 'Control de presión arterial y electrocardiograma.',
      tipo: TipoEventoAgenda.citaMedica,
      fechaHoraInicio: DateTime(2026, 6, 10, 10, 0),
      fechaHoraFin: DateTime(2026, 6, 10, 11, 0),
    ),
    // Evento futuro (próximo) con recordatorio activo — toma de medicación.
    EventoAgenda(
      id: 'evt_002',
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Toma de medicación matutina',
      descripcion: 'Atenolol 25 mg + Enalapril 10 mg.',
      tipo: TipoEventoAgenda.medicacion,
      fechaHoraInicio: DateTime(2026, 6, 7, 8, 0),
    ),
    // Evento futuro — fisioterapia.
    EventoAgenda(
      id: 'evt_003',
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Fisioterapia semanal',
      descripcion: 'Sesión de rehabilitación motriz.',
      tipo: TipoEventoAgenda.rehabilitacion,
      fechaHoraInicio: DateTime(2026, 6, 12, 14, 30),
      fechaHoraFin: DateTime(2026, 6, 12, 15, 30),
    ),
    // Evento vencido (hace 2 días) — para demostrar estado readonly (US-25).
    EventoAgenda(
      id: 'evt_004',
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Control de glucemia',
      descripcion: 'Medición de glucemia en ayunas.',
      tipo: TipoEventoAgenda.control,
      fechaHoraInicio: DateTime(2026, 6, 4, 9, 0),
    ),
    // Evento vencido (ayer) — segundo caso de evento pasado.
    EventoAgenda(
      id: 'evt_005',
      persona: personaAlicia,
      creadoPor: usuarioMaria,
      titulo: 'Medicación vespertina',
      descripcion: 'Metformina 500 mg con la cena.',
      tipo: TipoEventoAgenda.medicacion,
      fechaHoraInicio: DateTime(2026, 6, 5, 20, 0),
    ),
  ];

  // ─── Recordatorios de agenda ─────────────────────────────────────────────────

  /// Recordatorios iniciales para los eventos futuros de demostración.
  static final List<Recordatorio> recordatoriosAgenda = [
    Recordatorio(
      id: 'rec_001',
      eventoAgenda: eventosAgenda[0], // evt_001 — Consulta cardiológica
      fechaHoraEnvio: DateTime(2026, 6, 10, 10, 0),
    ),
    Recordatorio(
      id: 'rec_002',
      eventoAgenda: eventosAgenda[1], // evt_002 — Toma de medicación matutina
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
      id: 'hab_m01',
      persona: personaMaria,
      tipo: TipoHabito.actividadFisica,
      descripcion:
          'Caminata de 30 minutos antes del trabajo, cinco días a la semana.',
    ),
    HabitoDeVida(
      id: 'hab_m02',
      persona: personaMaria,
      tipo: TipoHabito.hidratacion,
      descripcion: 'Dos litros de agua por día. Recuerda beber entre comidas.',
    ),
  ];

  static final List<HabitoDeVida> habitosAlicia = [
    HabitoDeVida(
      id: 'hab_001',
      persona: personaAlicia,
      tipo: TipoHabito.actividadFisica,
      descripcion:
          'Caminata de 20 minutos por el parque, tres veces por semana.',
    ),
    HabitoDeVida(
      id: 'hab_002',
      persona: personaAlicia,
      tipo: TipoHabito.alimentacion,
      descripcion: 'Dieta baja en sodio y azúcares simples. Sin sal de mesa.',
    ),
    HabitoDeVida(
      id: 'hab_003',
      persona: personaAlicia,
      tipo: TipoHabito.hidratacion,
      descripcion: 'Ingesta de al menos 1,5 litros de agua por día.',
    ),
  ];

  // ─── Recomendaciones médicas ─────────────────────────────────────────────────

  static final List<RecomendacionMedica> recomendacionesAlicia = [
    RecomendacionMedica(
      id: 'rec_001',
      persona: personaAlicia,
      descripcion:
          'Controlar la presión arterial dos veces al día. Registrar valores.',
      fecha: DateTime(2026, 5, 15),
      profesional: 'Dr. Hernández (Cardiología)',
    ),
    RecomendacionMedica(
      id: 'rec_002',
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
      id: 'esa_m01',
      persona: personaMaria,
      tipo: TipoEventoSalud.citaMedica,
      fecha: DateTime(2026, 5, 20),
      descripcion: 'Control anual con médico clínico — Dr. Alejandro Torres.',
    ),
  ];

  static final EventoDeSalud eventoSaludMareos = EventoDeSalud(
    id: 'esa_001',
    persona: personaAlicia,
    tipo: TipoEventoSalud.sintoma,
    fecha: DateTime(2026, 5, 28),
    descripcion: 'Episodio de mareos al levantarse. Duración aprox. 5 minutos.',
  );

  static final EventoDeSalud eventoSaludControlCardiologico = EventoDeSalud(
    id: 'esa_003',
    persona: personaAlicia,
    tipo: TipoEventoSalud.citaMedica,
    fecha: DateTime(2026, 6, 2),
    descripcion: 'Control cardiológico — Dr. Martín Sosa · Hospital Italiano.',
  );

  static final List<EventoDeSalud> eventosSaludAlicia = [
    eventoSaludControlCardiologico,
    eventoSaludMareos,
    EventoDeSalud(
      id: 'esa_002',
      persona: personaAlicia,
      tipo: TipoEventoSalud.vacuna,
      fecha: DateTime(2026, 4, 3),
      descripcion: 'Vacuna antigripal anual.',
    ),
  ];

  // ─── Notas de eventos de salud ───────────────────────────────────────────────

  static final List<NotaEvento> notasEvento = [
    NotaEvento(
      id: 'not_001',
      eventoSaludId: 'esa_003',
      autor: personaMaria,
      fechaHora: DateTime(2026, 6, 2, 14, 32),
      contenido:
          'El médico indicó repetir análisis en 3 meses. Solicitar turno a fin de mes.',
    ),
    NotaEvento(
      id: 'not_002',
      eventoSaludId: 'esa_003',
      autor: personaLaura,
      fechaHora: DateTime(2026, 6, 3, 9, 15),
      contenido: 'Acordado con Alicia hacer los análisis en Fleni.',
    ),
    NotaEvento(
      id: 'not_003',
      eventoSaludId: 'esa_001',
      autor: personaMaria,
      fechaHora: DateTime(2026, 5, 28, 11, 0),
      contenido:
          'Presión se normalizó a los 15 minutos. Se informó al cardiólogo por WhatsApp.',
    ),
    // Nota migrada desde el campo notas del evento esa_001.
    NotaEvento(
      id: 'not_004',
      eventoSaludId: 'esa_001',
      autor: personaMaria,
      fechaHora: DateTime(2026, 5, 28, 10, 5),
      contenido: 'Presión al momento: 90/60. Se la acostó y pasó solo.',
    ),
    // Nota migrada desde el campo notas del evento esa_m01 (María).
    NotaEvento(
      id: 'not_005',
      eventoSaludId: 'esa_m01',
      autor: personaMaria,
      fechaHora: DateTime(2026, 5, 20, 12, 0),
      contenido: 'Todo en orden. Indicó análisis de laboratorio en 6 meses.',
    ),
  ];

  // ─── Estados de ánimo ────────────────────────────────────────────────────────

  static final List<EstadoDeAnimo> estadosAnimoAlicia = [
    EstadoDeAnimo(
      id: 'ani_001',
      persona: personaAlicia,
      fecha: DateTime(2026, 6, 4),
      estado: EstadoAnimoEnum.bien,
      observaciones: 'Estuvo animada en el desayuno.',
    ),
    EstadoDeAnimo(
      id: 'ani_002',
      persona: personaAlicia,
      eventoDeSalud: eventoSaludMareos,
      fecha: DateTime(2026, 5, 28),
      estado: EstadoAnimoEnum.mal,
      observaciones: 'Preocupada tras el episodio de mareos.',
    ),
  ];

  // ─── Aceptaciones de términos ────────────────────────────────────────────────

  static final List<AceptacionTerminos> aceptacionesMaria = [
    AceptacionTerminos(
      id: 'acc_001',
      usuario: usuarioMaria,
      version: '1.0',
      fechaAceptacion: DateTime(2024, 1, 8),
    ),
  ];
}
