import 'package:flutter/material.dart';
import 'package:goyolingua/core/widgets/widgetsTeoria/video_player.dart';

class MuestraTeoria extends StatelessWidget {
  final String nombreLeccion;
  final String texto;
  final String? videoUrl;
  final String? imagenUrl;

  const MuestraTeoria({
    Key? key,
    required this.nombreLeccion,
    required this.texto,
    this.videoUrl,
    this.imagenUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreLeccion),
        // Para retroceder entre las lecciones
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carga un video en caso de que encuentres el video
            if (videoUrl != null && videoUrl!.isNotEmpty)
              VideoPlayerWidget(videoUrl: videoUrl!),
            const SizedBox(height: 16),
            // Carga el texto en caso de que encuentres el texto
            Text(
              texto,
              style: const TextStyle(fontSize: 16),
            ),
            // Carga la imagen en dado caso que lo encuentres
            if (imagenUrl != null && imagenUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Image.network(imagenUrl!),
              ),
          ],
        ),
      ),
    );
  }
}
