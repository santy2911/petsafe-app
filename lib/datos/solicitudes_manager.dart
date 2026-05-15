import '../modelos/animal.dart';

enum EstadoSolicitud { pendiente, aceptada, rechazada }

class Solicitud {
  final String id;
  final Animal animal;
  EstadoSolicitud estado;
  final DateTime fecha;

  Solicitud({
    required this.id,
    required this.animal,
    required this.estado,
    required this.fecha,
  });
}

// Singleton en memoria para las solicitudes de adopcion.
// En produccion reemplazar por Riverpod + backend.
class SolicitudesManager {
  static final SolicitudesManager _instancia = SolicitudesManager._();
  SolicitudesManager._();
  factory SolicitudesManager() => _instancia;

  final List<Solicitud> _solicitudes = [];

  List<Solicitud> get solicitudes => List.unmodifiable(_solicitudes);

  bool tieneSolicitud(String animalId) =>
      _solicitudes.any((s) => s.animal.id == animalId);

  void agregar(Animal animal) {
    if (tieneSolicitud(animal.id)) return;
    _solicitudes.insert(
      0,
      Solicitud(
        id:     DateTime.now().millisecondsSinceEpoch.toString(),
        animal: animal,
        estado: EstadoSolicitud.pendiente,
        fecha:  DateTime.now(),
      ),
    );
  }

  void eliminar(String id) => _solicitudes.removeWhere((s) => s.id == id);
}