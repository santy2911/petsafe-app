class SolicitudAdopcion {
  final String id;
  final String idUsuario;
  final String idAnimal;
  final String estado; // 'pendiente', 'aceptada', 'rechazada'
  final String comentarios;
  final DateTime fecha;

  SolicitudAdopcion({
    required this.id,
    required this.idUsuario,
    required this.idAnimal,
    required this.estado,
    required this.comentarios,
    required this.fecha,
  });

  factory SolicitudAdopcion.fromJson(Map<String, dynamic> json) {
    return SolicitudAdopcion(
      id: json['id'].toString(),
      idUsuario: json['idUsuario'].toString(),
      idAnimal: json['idAnimal'].toString(),
      estado: json['estado'] ?? 'pendiente',
      comentarios: json['comentarios'] ?? '',
      fecha: DateTime.parse(json['fecha']),
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
    };
  }
}