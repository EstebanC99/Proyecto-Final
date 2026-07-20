import 'package:flutter/material.dart';

/// Visor de imagen a pantalla (casi) completa con zoom y desplazamiento.
///
/// Muestra la imagen dada sobre un fondo oscuro semitransparente, con soporte
/// de zoom/pan mediante [InteractiveViewer]. Se cierra al tocar fuera de la
/// imagen o el botón de cerrar. Es puramente presentacional.
abstract final class ImageViewerDialog {
  /// Abre el visor con la imagen [imageProvider].
  static Future<void> show(BuildContext context, ImageProvider imageProvider) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          elevation: 0,
          child: Stack(
            children: [
              // Toca fuera de la imagen para cerrar.
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
              // Imagen con zoom/pan.
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image(image: imageProvider, fit: BoxFit.contain),
                ),
              ),
              // Botón de cerrar.
              Positioned(
                top: 8,
                right: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
