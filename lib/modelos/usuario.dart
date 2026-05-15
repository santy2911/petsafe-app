class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String imagenUrl;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.imagenUrl,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      imagenUrl: json['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'imagenUrl': imagenUrl,
    };
  }
}