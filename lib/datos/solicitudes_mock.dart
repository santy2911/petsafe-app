import '../modelos/solicitud_adopcion.dart';

final solicitudesMock = [
  SolicitudAdopcion(
    id: '1',
    idUsuario: '2',
    idAnimal: '1',
    nombreUsuario: 'Juan Pérez',
    nombreAnimal: 'Luna',
    estado: 'Pendiente',
    mensaje: 'Hola, me encantaría adoptar a Luna. Tengo espacio y tiempo para ella.',
    comentarios: '',
    fecha: DateTime.now().subtract(const Duration(days: 1)),
  ),
  SolicitudAdopcion(
    id: '2',
    idUsuario: '3',
    idAnimal: '2',
    nombreUsuario: 'María García',
    nombreAnimal: 'Toby',
    estado: 'Aceptada',
    mensaje: 'Tengo otro perro y creo que Toby se llevaría genial con él.',
    comentarios: '',
    fecha: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
