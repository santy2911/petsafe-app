import '../modelos/reporte.dart';
import '../datos/reportes_mock.dart';
import 'api_service.dart';
import '../servicios/auth_service.dart';

class ReportesService {

  static Future<List<Reporte>> getReportes() async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get('/reportes', token: AuthService.token);
    // return (data as List).map((e) => Reporte.fromJson(e)).toList();

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    return reportesMock;
  }

  static Future<void> crearReporte(Reporte reporte) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.post('/reportes', reporte.toJson(), token: AuthService.token);

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    reportesMock.add(reporte);
  }

  static Future<void> actualizarReporte(Reporte reporte) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.put('/reportes/${reporte.id}', reporte.toJson(), token: AuthService.token);

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    final index = reportesMock.indexWhere((r) => r.id == reporte.id);
    if (index != -1) reportesMock[index] = reporte;
  }

  static Future<void> marcarEncontrado(String id) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.put('/reportes/$id/encontrado', {}, token: AuthService.token);

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    final reporte = reportesMock.firstWhere((r) => r.id == id);
    reporte.encontrado = true;
  }
}