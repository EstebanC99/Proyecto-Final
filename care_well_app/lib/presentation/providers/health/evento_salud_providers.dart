import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//region Acciones de Consulta

/// Trunca [fecha] a año-mes-día (medianoche local).
DateTime _soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

/// Ventana hacia atrás en la que se busca el evento previo al día seleccionado
/// (sección "Anteriormente"). Es más amplia que la de la agenda porque los
/// eventos de salud son esporádicos.
const _ventanaEventoAnterior = Duration(days: 90);

/// Lunes de la semana actualmente visible en la tira de días de los eventos
/// de salud.
final semanaEventosSaludProvider = StateProvider<DateTime>(
  (ref) => lunesDeLaSemana(DateTime.now()),
);

/// Día cuyo detalle se está mostrando (truncado a año-mes-día).
final diaEventosSaludSeleccionadoProvider = StateProvider<DateTime>(
  (ref) => _soloFecha(DateTime.now()),
);

/// Mueve la pantalla de eventos de salud al día indicado: lo selecciona y, si
/// cae fuera de la semana visible, mueve también la semana.
///
/// El día se acota a hoy: los eventos de salud se registran después de ocurrir,
/// así que nunca se selecciona un día futuro. Lo usan la pantalla (al tocar un
/// día de la tira o "Anteriormente") y el formulario de alta, para que al
/// volver quede a la vista el evento recién registrado.
void seleccionarDiaEventosSalud(WidgetRef ref, DateTime dia) {
  final hoy = _soloFecha(DateTime.now());
  final pedido = _soloFecha(dia);
  final objetivo = pedido.isAfter(hoy) ? hoy : pedido;

  ref.read(diaEventosSaludSeleccionadoProvider.notifier).state = objetivo;

  final lunes = lunesDeLaSemana(objetivo);
  if (lunes != ref.read(semanaEventosSaludProvider)) {
    ref.read(semanaEventosSaludProvider.notifier).state = lunes;
  }
}

/// Eventos de salud de la persona de contexto dentro de la semana seleccionada
/// (lunes a domingo), ordenados por fecha/hora ascendente.
final eventosSaludDeSemanaProvider = FutureProvider<List<EventoSalud>>((
  ref,
) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return [];

  final lunes = ref.watch(semanaEventosSaludProvider);

  final eventos = await ref
      .watch(eventoSaludRepositoryProvider)
      .getEventosSaludDelMes(
        personaId: persona.id,
        desde: lunes,
        hasta: lunes.add(const Duration(days: 7)),
      );
  eventos.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return eventos;
});

/// Evento de salud más reciente ANTERIOR al día seleccionado, dentro de los
/// últimos 90 días. Alimenta la sección "Anteriormente".
///
/// Los eventos de salud se registran después de ocurrir, por lo que no existe
/// un equivalente a "lo que sigue": la sección mira siempre hacia atrás.
final eventoSaludAnteriorProvider = FutureProvider<EventoSalud?>((ref) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return null;

  // `hasta` es exclusivo: el evento previo nunca puede ser del día que ya se
  // está viendo. El filtro posterior lo garantiza aunque el origen de datos
  // interprete el límite como inclusivo.
  final hasta = _soloFecha(ref.watch(diaEventosSaludSeleccionadoProvider));
  final desde = hasta.subtract(_ventanaEventoAnterior);
  final ahora = DateTime.now();

  final eventos = await ref
      .watch(eventoSaludRepositoryProvider)
      .getEventosSaludDelMes(personaId: persona.id, desde: desde, hasta: hasta);

  final anteriores =
      eventos
          .where(
            (e) => e.fechaHora.isBefore(hasta) && !e.fechaHora.isAfter(ahora),
          )
          .toList()
        ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
  return anteriores.firstOrNull;
});

final eventoSaludByIdProvider = FutureProvider.family<EventoSalud?, int>((
  ref,
  id,
) async {
  final eventos = await ref.watch(eventosSaludDeSemanaProvider.future);
  return eventos.where((e) => e.id == id).firstOrNull;
});

final notasByEventoProvider = Provider.family<List<NotaEventoSalud>, int>((
  ref,
  eventoId,
) {
  final eventos = ref.watch(eventosSaludDeSemanaProvider).value ?? [];
  final evento = eventos.where((e) => e.id == eventoId).firstOrNull;
  final notas = [...?evento?.notas];
  notas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return notas;
});

//endregion

//region Acciones Mutadoras

/// Invalida todas las vistas de eventos de salud tras una mutación.
void _invalidarEventosSalud(Ref ref) {
  ref.invalidate(eventosSaludDeSemanaProvider);
  ref.invalidate(eventoSaludAnteriorProvider);
}

final crearEventoSaludProvider =
    Provider<
      Future<void> Function({
        required int tipoId,
        required String descripcion,
        required DateTime fechaHora,
      })
    >((ref) {
      return ({
        required tipoId,
        required descripcion,
        required fechaHora,
      }) async {
        final persona = await ref.read(
          personaVisualizacionSeleccionadaProvider.future,
        );
        if (persona == null) throw Exception('Sin persona de contexto');

        await ref
            .read(eventoSaludRepositoryProvider)
            .crearEventoSalud(
              personaId: persona.id,
              tipoId: tipoId,
              fechaHora: fechaHora,
              descripcion: descripcion,
            );
        _invalidarEventosSalud(ref);
      };
    });

final eliminarEventoSaludProvider =
    Provider<Future<void> Function({required int eventoId})>((ref) {
      return ({required eventoId}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .eliminarEventoSalud(eventoId);
        _invalidarEventosSalud(ref);
      };
    });

final agregarNotaEventoProvider =
    Provider<
      Future<void> Function({
        required int eventoSaludId,
        required String contenido,
      })
    >((ref) {
      return ({required eventoSaludId, required contenido}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .agregarNota(eventoSaludId: eventoSaludId, contenido: contenido);
        _invalidarEventosSalud(ref);
      };
    });

final modificarNotaEventoProvider =
    Provider<
      Future<void> Function({
        required int eventoSaludId,
        required int notaId,
        required String contenido,
      })
    >((ref) {
      return ({
        required eventoSaludId,
        required notaId,
        required contenido,
      }) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .modificarNota(
              eventoSaludId: eventoSaludId,
              notaId: notaId,
              contenido: contenido,
            );
        _invalidarEventosSalud(ref);
      };
    });

final eliminarNotaEventoProvider =
    Provider<
      Future<void> Function({required int eventoSaludId, required int notaId})
    >((ref) {
      return ({required eventoSaludId, required notaId}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .eliminarNota(eventoSaludId: eventoSaludId, notaId: notaId);
        _invalidarEventosSalud(ref);
      };
    });

//endregion
