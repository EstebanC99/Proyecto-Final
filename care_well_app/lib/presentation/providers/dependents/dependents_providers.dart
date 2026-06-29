import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/auth/auth_providers.dart';
import 'package:care_well_app/presentation/providers/shared/asignaciones_providers.dart';
import 'package:care_well_app/presentation/providers/di_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crearPersonaCargoProvider =
    Provider<
      Future<void> Function({
        required String nombre,
        required String apellido,
        required String documento,
        required DateTime fechaNacimiento,
        String? email,
        String? telefono,
        String? imagen,
      })
    >((ref) {
      return ({
        required nombre,
        required apellido,
        required documento,
        required fechaNacimiento,
        email,
        telefono,
        imagen,
      }) async {
        final usuario = ref.read(authStateProvider).valueOrNull;
        if (usuario == null) throw Exception('No hay sesión activa.');

        final asignacionRepo = ref.read(asignacionCuidadoRepositoryProvider);

        await asignacionRepo.crearPersonaCargo(
          nombre: nombre,
          apellido: apellido,
          documento: documento,
          fechaNacimiento: fechaNacimiento,
          email: email,
          telefono: telefono,
        );

        ref.invalidate(misAsignacionesProvider);
      };
    });

final actualizarPersonaCargoProvider =
    Provider<Future<Persona> Function(int asignacionId, Persona persona)>((
      ref,
    ) {
      return (asignacionId, persona) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);
        final actualizada = await repo.modificarPersonaCargo(
          asignacionId,
          persona,
        );
        ref.invalidate(misAsignacionesProvider);
        return actualizada;
      };
    });
