import 'package:care_well_app/domain/entities/care_team/permiso_cuidado.dart';
import 'package:care_well_app/domain/global/permisos_cuidado_const.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Modificar por ida al backend para obtener todos los permisos y también para el GetByID en caso de necesitarse.
final _permisosCuidado = [
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

final availablePermisosProvider = Provider<List<PermisoCuidado>>(
  (ref) => _permisosCuidado,
);
