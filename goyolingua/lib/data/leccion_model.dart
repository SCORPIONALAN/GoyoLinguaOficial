class Leccion {
  final String nombre;
  final String texto;
  final String? videoUrl;
  final String? imagenUrl;

  Leccion({
    required this.nombre,
    required this.texto,
    this.videoUrl,
    this.imagenUrl,
  });
  //El factory permite definir un constructor especial (Patron de diseño Singleton), para devolver una instancia existente
  //para devolver informacion traida de fireStore convertirla a Leccion y hace validaciones
  factory Leccion.fromFirestore(Map<String, dynamic> data) {
    return Leccion(
      nombre: data['Tema'] ?? '',
      texto: data['Texto'] ?? '',
      videoUrl:
          (data['Video'] as String?)?.isNotEmpty == true ? data['Video'] : null,
      imagenUrl: (data['Imagen'] as String?)?.isNotEmpty == true
          ? data['Imagen']
          : null,
    );
  }
}
