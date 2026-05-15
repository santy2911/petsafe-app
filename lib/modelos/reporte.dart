class Reporte {
  final String id;
  String nombre;
  String raza;
  String especie;
  String descripcion;
  String telefono;
  final String imagenUrl;
  final double latitud;
  final double longitud;
  String direccion;
  final DateTime fecha;
  bool encontrado;

  Reporte({
    required this.id,
    required this.nombre,
    required this.raza,
    required this.especie,
    required this.descripcion,
    required this.telefono,
    required this.imagenUrl,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    required this.fecha,
    this.encontrado = false,
  });

  Reporte copyWith({
    String? id,
    String? nombre,
    String? raza,
    String? especie,
    String? descripcion,
    String? telefono,
    String? imagenUrl,
    double? latitud,
    double? longitud,
    String? direccion,
    DateTime? fecha,
    bool? encontrado,
  }) {
    return Reporte(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      raza: raza ?? this.raza,
      especie: especie ?? this.especie,
      descripcion: descripcion ?? this.descripcion,
      telefono: telefono ?? this.telefono,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccion: direccion ?? this.direccion,
      fecha: fecha ?? this.fecha,
      encontrado: encontrado ?? this.encontrado,
    );
  }

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      raza: json['raza'] ?? '',
      especie: json['especie'] ?? '',
      descripcion: json['descripcion'] ?? '',
      telefono: json['telefono'] ?? '',
      imagenUrl: json['imagenUrl'] ?? '',
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      direccion: json['direccion'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      encontrado: json['encontrado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'raza': raza,
      'especie': especie,
      'descripcion': descripcion,
      'telefono': telefono,
      'imagenUrl': imagenUrl,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'fecha': fecha.toIso8601String(),
      'encontrado': encontrado,
    };
  }
}