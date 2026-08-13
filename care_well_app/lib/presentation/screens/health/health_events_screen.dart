import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Eventos de salud de la persona de contexto (US-30).
///
/// Muestra una tira con los siete días de la semana seleccionada y el detalle
/// del día elegido, más una sección "Anteriormente" con el último evento
/// registrado antes de ese día. Como los eventos de salud se registran después
/// de ocurrir, no se puede navegar a semanas futuras ni seleccionar días
/// posteriores a hoy. Para usuarios con permiso
/// [PermisosCuidadoConst.registrarEventosSalud] permite registrar nuevos
/// eventos mediante el FAB.
class HealthEventsScreen extends ConsumerStatefulWidget {
  const HealthEventsScreen({super.key});

  @override
  ConsumerState<HealthEventsScreen> createState() => _HealthEventsScreenState();
}

class _HealthEventsScreenState extends ConsumerState<HealthEventsScreen> {
  @override
  void initState() {
    super.initState();
    // Cada entrada arranca en el presente: la selección de día y semana vive
    // en providers globales y, si no se reinicia, la pantalla se abre donde
    // quedó la visita anterior.
    //
    // El reinicio va en un microtask porque Riverpod prohíbe modificar un
    // provider dentro de un ciclo de vida del widget. Se resuelve antes del
    // primer frame, así que no se llega a ver la semana vieja.
    //
    // No se resuelve marcando los providers como `autoDispose` porque el
    // formulario de alta se apila encima de esta pantalla sin desmontarla: eso
    // los mantendría vivos igual, y además rompería el salto al día del evento
    // recién registrado.
    Future.microtask(() {
      if (mounted) reiniciarSeleccionEventosSalud(ref);
    });
  }

  /// Trunca una fecha a año-mes-día.
  DateTime _soloFecha(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  /// Selecciona un día y, si cae fuera de la semana visible, mueve también la
  /// semana. Permite saltar al evento de "Anteriormente" sin pasos extra.
  void _seleccionarDia(DateTime dia) => seleccionarDiaEventosSalud(ref, dia);

  void _irASemanaAnterior() {
    final lunes = ref.read(semanaEventosSaludProvider);
    ref.read(semanaEventosSaludProvider.notifier).state = lunes.subtract(
      const Duration(days: 7),
    );
  }

  void _irASemanaSiguiente() {
    final lunes = ref.read(semanaEventosSaludProvider);
    ref.read(semanaEventosSaludProvider.notifier).state = lunes.add(
      const Duration(days: 7),
    );
  }

  /// Agrupa la cantidad de eventos por día, para los pips de la tira.
  Map<DateTime, int> _cantidadPorDia(List<EventoSalud> eventos) {
    final Map<DateTime, int> conteo = {};
    for (final e in eventos) {
      final dia = _soloFecha(e.fechaHora.toLocal());
      conteo[dia] = (conteo[dia] ?? 0) + 1;
    }
    return conteo;
  }

  @override
  Widget build(BuildContext context) {
    final eventosAsync = ref.watch(eventosSaludDeSemanaProvider);
    final puede = ref.watch(puedeRegistrarEventosSaludProvider).value ?? false;
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final lunesSemana = ref.watch(semanaEventosSaludProvider);
    final diaSeleccionado = ref.watch(diaEventosSaludSeleccionadoProvider);

    final ahora = DateTime.now();
    final hoy = _soloFecha(ahora);
    final esSemanaActual = lunesSemana == lunesDeLaSemana(ahora);

    // Filtro defensivo: nunca mostrar eventos con fecha futura.
    final eventosSemana = (eventosAsync.value ?? const <EventoSalud>[])
        .where((e) => !e.fechaHora.isAfter(ahora))
        .toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const ContextAppBar(eyebrow: 'Eventos de salud'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tira de la semana. No se puede avanzar más allá de la semana
          // actual: los eventos de salud se registran después de ocurrir.
          WeekStrip(
            lunesSemana: lunesSemana,
            diaSeleccionado: diaSeleccionado,
            cantidadPorDia: _cantidadPorDia(eventosSemana),
            onSelectDia: _seleccionarDia,
            onPreviousWeek: _irASemanaAnterior,
            onNextWeek: esSemanaActual ? null : _irASemanaSiguiente,
            accentColor: context.colors.healthAccent,
            maxDiaSeleccionable: hoy,
          ),

          Expanded(
            child: eventosAsync.when(
              loading: () => const _EventosSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InlineErrorBanner(
                    message: 'No se pudieron cargar los eventos. $err',
                  ),
                ),
              ),
              data: (_) {
                if (personaAsync.value == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver sus eventos de salud.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }

                final delDia = eventosSemana
                    .where(
                      (e) =>
                          _soloFecha(e.fechaHora.toLocal()) ==
                          _soloFecha(diaSeleccionado),
                    )
                    .toList();

                return RefreshIndicator(
                  color: context.colors.healthAccent,
                  onRefresh: () async {
                    ref.invalidate(eventosSaludDeSemanaProvider);
                    ref.invalidate(eventoSaludAnteriorProvider);
                    await ref.read(eventosSaludDeSemanaProvider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                    children: [
                      DayHeader(
                        dia: diaSeleccionado,
                        cantidadEventos: delDia.length,
                      ),

                      // Sin eventos en toda la semana se muestra el estado
                      // vacío completo (con CTA); si solo está vacío el día,
                      // alcanza un mensaje breve que no tape la tira ni la
                      // sección "Anteriormente".
                      if (delDia.isEmpty && eventosSemana.isEmpty)
                        _EmptyWeekState(puede: puede)
                      else if (delDia.isEmpty)
                        _SinEventosEnElDia(puede: puede)
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final e in delDia)
                                HealthEventCard(
                                  evento: e,
                                  mostrarFecha: false,
                                  tieneNotas: e.tieneNotas,
                                  onTap: () => context.pushNamed(
                                    AppRoutes.healthEventDetailName,
                                    pathParameters: {'id': e.id.toString()},
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // "Anteriormente": último evento previo al día visible.
                      _EventoAnteriorSection(onVerDia: _seleccionarDia),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: puede
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.healthEventsNewName),
              tooltip: 'Nuevo evento de salud',
              backgroundColor: context.colors.healthAccent,
              child: Icon(Icons.add, color: context.colors.onPrimary),
            )
          : null,
    );
  }
}

// ─── Sección "Anteriormente" ─────────────────────────────────────────────────

/// Muestra el último evento de salud anterior al día seleccionado.
///
/// Es informativa: al tocarla se salta a ese día en lugar de abrir el detalle,
/// que se accede desde las cards del día que se está viendo.
class _EventoAnteriorSection extends ConsumerWidget {
  const _EventoAnteriorSection({required this.onVerDia});

  final ValueChanged<DateTime> onVerDia;

  static const _nombresDiaCorto = [
    'LUN',
    'MAR',
    'MIÉ',
    'JUE',
    'VIE',
    'SÁB',
    'DOM',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anterior = ref.watch(eventoSaludAnteriorProvider).value;
    if (anterior == null) return const SizedBox.shrink();

    final fechaHora = anterior.fechaHora.toLocal();
    final hora =
        '${fechaHora.hour.toString().padLeft(2, '0')}:'
        '${fechaHora.minute.toString().padLeft(2, '0')}';
    final acento = healthEventColor(context, anterior.tipo);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: context.colors.outline, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'ANTERIORMENTE',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => onVerDia(fechaHora),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: acento.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      '${_nombresDiaCorto[fechaHora.weekday - 1]} '
                      '${fechaHora.day}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: acento,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      anterior.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    ' · $hora',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Estado vacío de la semana ───────────────────────────────────────────────

class _EmptyWeekState extends StatelessWidget {
  const _EmptyWeekState({required this.puede});

  final bool puede;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: context.colors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sin eventos en esta semana.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (puede)
            Text(
              'Usá el botón + para registrar un evento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textDisabled,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Estado vacío del día ────────────────────────────────────────────────────

/// Mensaje breve cuando el día seleccionado no tiene eventos.
///
/// Se prefiere al estado vacío completo porque acá siempre queda visible la
/// tira de días y la sección "Anteriormente".
class _SinEventosEnElDia extends StatelessWidget {
  const _SinEventosEnElDia({required this.puede});

  final bool puede;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_outline,
            size: 40,
            color: context.colors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No hay eventos este día',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
          if (puede) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Usá el botón + para registrar uno.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Skeleton de carga ────────────────────────────────────────────────────────

class _EventosSkeleton extends StatelessWidget {
  const _EventosSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          ...List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
