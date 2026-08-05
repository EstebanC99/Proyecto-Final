import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/theme/app_palette.dart';
import 'image_source_sheet.dart';

/// Muestra la hoja de selección de origen, abre el selector/cámara, permite
/// recortar la imagen con un preset tipo tarjeta de documento y la devuelve
/// codificada en base64 estándar (sin prefijo data-URI).
///
/// A diferencia de `pickImageAsBase64` (foto de perfil), esta captura está
/// pensada para lectura OCR/IA del documento: usa mayor resolución (1600px) y
/// calidad (85), y un recorte rectangular con relación de aspecto de tarjeta
/// (~1.585:1, formato ISO/IEC 7810 ID-1), en vez del recorte circular 1:1.
///
/// Devuelve `null` si el usuario cancela en cualquier paso (elección de origen,
/// selección de imagen o recorte).
///
/// Privacidad: la imagen es PII sensible. Solo se codifica en memoria y se
/// devuelve al llamador; no se cachea en disco ni se registra en logs.
Future<String?> pickDocumentImageAsBase64(BuildContext context) async {
  // Se captura antes de los `await`: la UI nativa del cropper no participa del
  // árbol de widgets y no puede leer el tema después del gap asincrónico.
  final palette = context.colors;

  final source = await ImageSourceSheet.show(
    context,
    title: 'Foto del documento',
  );
  if (source == null) return null;

  final xfile = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 85,
  );
  if (xfile == null) return null;

  // Recorte rectangular con relación de aspecto de tarjeta de documento.
  final cropped = await ImageCropper().cropImage(
    sourcePath: xfile.path,
    aspectRatio: const CropAspectRatio(ratioX: 1.585, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 85,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Recortar documento',
        toolbarColor: palette.primary,
        toolbarWidgetColor: palette.onPrimary,
        activeControlsWidgetColor: palette.primary,
        lockAspectRatio: true,
        hideBottomControls: true,
      ),
      IOSUiSettings(title: 'Recortar documento', aspectRatioLockEnabled: true),
    ],
  );
  if (cropped == null) return null;

  final bytes = await cropped.readAsBytes();
  return base64Encode(bytes);
}
