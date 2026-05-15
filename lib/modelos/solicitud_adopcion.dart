class SolicitudAdopcion {
  final String id;
  final String idUsuario;
  final String idAnimal;
  final String estado; // 'pendiente', 'aceptada', 'rechazada'
  final String comentarios;
  final DateTime fecha;
  final String mensaje;
  final String nombreUsuario;
  final String nombreAnimal;
  final String urlImagenAnimal;

  SolicitudAdopcion({
    required this.id,
    required this.idUsuario,
    required this.idAnimal,
    required this.estado,
    required this.comentarios,
    required this.fecha,
    this.mensaje = '',
    this.nombreUsuario = 'Usuario',
    this.nombreAnimal = 'Animal',
    this.urlImagenAnimal = 'https://images.unsplash.com/photo-1543466835-00a732f3af04?auto=format&fit=crop&q=80&w=200',
  });

  SolicitudAdopcion copyWith({
    String? id,
    String? idUsuario,
    String? idAnimal,
    String? estado,
    String? comentarios,
    DateTime? fecha,
    String? mensaje,
    String? nombreUsuario,
    String? nombreAnimal,
    String? urlImagenAnimal,
  }) {
    return SolicitudAdopcion(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      idAnimal: idAnimal ?? this.idAnimal,
      estado: estado ?? this.estado,
      comentarios: comentarios ?? this.comentarios,
      fecha: fecha ?? this.fecha,
      mensaje: mensaje ?? this.mensaje,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      nombreAnimal: nombreAnimal ?? this.nombreAnimal,
      urlImagenAnimal: urlImagenAnimal ?? this.urlImagenAnimal,
    );
  }

  factory SolicitudAdopcion.fromJson(Map<String, dynamic> json) {
    return SolicitudAdopcion(
      id: json['id'].toString(),
      idUsuario: json['idUsuario'].toString(),
      idAnimal: json['idAnimal'].toString(),
      estado: json['estado'] ?? 'pendiente',
      comentarios: json['comentarios'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      mensaje: json['mensaje'] ?? '',
      nombreUsuario: json['nombreUsuario'] ?? 'Usuario',
      nombreAnimal: json['nombreAnimal'] ?? 'Animal',
      urlImagenAnimal: json['urlImagenAnimal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'idAnimal': idAnimal,
      'estado': estado,
      'comentarios': comentarios,
      'fecha': fecha.toIso8601String(),
      'mensaje': mensaje,
      'nombreUsuario': nombreUsuario,
      'nombreAnimal': nombreAnimal,
      'urlImagenAnimal': urlImagenAnimal,
    };
  }

  // Alias para retrocompatibilidad con pantallas que usen nombres antiguos
  DateTime get fechaSolicitud => fecha;
}