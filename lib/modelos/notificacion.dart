class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo; // 'adopcion', 'mascota_perdida', 'recompensa', 'sistema'
  final String? idEntidad; // ID del animal o reporte relacionado
  final DateTime fecha;
  final bool leida;

  const Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.idEntidad,
    required this.fecha,
    this.leida = false,
  });

  Notificacion copyWith({bool? leida}) {
    return Notificacion(
      id: id,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      idEntidad: idEntidad,
      fecha: fecha,
      leida: leida ?? this.leida,
    );
  }

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'].toString(),
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: json['tipo'] ?? 'sistema',
      idEntidad: json['idEntidad'],
      fecha: DateTime.parse(json['fecha']),
      leida: json['leida'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'idEntidad': idEntidad,
      'fecha': fecha.toIso8601String(),
      'leida': leida,
    };
  }
}