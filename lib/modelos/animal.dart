class Animal {
  final String id;
  final String nombre;
  final String especie;
  final String raza;
  final int edad;
  final String sexo;
  final String descripcion;
  final String imagenUrl;
  final bool disponible;
  final String peso;
  final bool vacunado;
  final bool esterilizado;
  final bool microchip;
  final String refugio;
  final String ubicacionRefugio;

  Animal({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.sexo,
    required this.descripcion,
    required this.imagenUrl,
    required this.disponible,
    required this.peso,
    required this.vacunado,
    required this.esterilizado,
    required this.microchip,
    required this.refugio,
    required this.ubicacionRefugio,
  });
  factory Animal.fromJson(Map<String, dynamic> json) {
  return Animal(
    id: json['id'].toString(),
    nombre: json['nombre'] ?? '',
    especie: json['especie'] ?? '',
    raza: json['raza'] ?? '',
    edad: json['edad'] ?? 0,
    sexo: json['sexo'] ?? '',
    descripcion: json['descripcion'] ?? '',
    imagenUrl: json['imagenUrl'] ?? '',
    disponible: json['disponible'] ?? true,
    peso: json['peso'] ?? '',
    vacunado: json['vacunado'] ?? false,
    esterilizado: json['esterilizado'] ?? false,
    microchip: json['microchip'] ?? false,
    refugio: json['refugio'] ?? '',
    ubicacionRefugio: json['ubicacionRefugio'] ?? '',
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'nombre': nombre,
    'especie': especie,
    'raza': raza,
    'edad': edad,
    'sexo': sexo,
    'descripcion': descripcion,
    'imagenUrl': imagenUrl,
    'disponible': disponible,
    'peso': peso,
    'vacunado': vacunado,
    'esterilizado': esterilizado,
    'microchip': microchip,
    'refugio': refugio,
    'ubicacionRefugio': ubicacionRefugio,
  };
}
}