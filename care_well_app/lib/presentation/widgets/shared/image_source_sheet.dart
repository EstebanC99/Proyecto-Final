import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Hoja inferior para elegir el origen de una imagen (cámara o galería).
///
/// Reutiliza el enum [ImageSource] del paquete `image_picker`. Es puramente
/// presentacional: retorna el [ImageSource] elegido (o `null` si se descarta).
abstract final class ImageSourceSheet {
  /// Muestra la hoja de selección y retorna el origen elegido.
  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'Foto de perfil',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _OrigenTile(
                icon: Icons.photo_camera_outlined,
                label: 'Tomar foto',
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              _OrigenTile(
                icon: Icons.photo_library_outlined,
                label: 'Elegir de galería',
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}

/// Muestra la hoja de selección de origen, abre el selector/cámara, permite
/// recortar la imagen en formato cuadrado (1:1, con overlay circular) y la
/// devuelve codificada en base64 estándar (sin prefijo data-URI).
///
/// Devuelve `null` si el usuario cancela en cualquier paso (elección de origen,
/// selección de imagen o recorte). La imagen se redimensiona a 1024px máximo y
/// se comprime a calidad 75 antes de codificar.
Future<String?> pickImageAsBase64(BuildContext context) async {
  final source = await ImageSourceSheet.show(context);
  if (source == null) return null;

  final xfile = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 75,
  );
  if (xfile == null) return null;

  // Recorte cuadrado (1:1) con overlay circular, coherente con el avatar.
  final cropped = await ImageCropper().cropImage(
    sourcePath: xfile.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 75,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Recortar foto',
        toolbarColor: AppColors.primary,
        toolbarWidgetColor: AppColors.surface,
        activeControlsWidgetColor: AppColors.primary,
        cropStyle: CropStyle.circle,
        lockAspectRatio: true,
        hideBottomControls: true,
        aspectRatioPresets: const [CropAspectRatioPreset.square],
      ),
      IOSUiSettings(
        title: 'Recortar foto',
        cropStyle: CropStyle.circle,
        aspectRatioLockEnabled: true,
        aspectRatioPresets: const [CropAspectRatioPreset.square],
      ),
    ],
  );
  if (cropped == null) return null;

  final bytes = await cropped.readAsBytes();
  return base64Encode(bytes);
}

class _OrigenTile extends StatelessWidget {
  const _OrigenTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
