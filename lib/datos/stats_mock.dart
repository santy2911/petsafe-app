class AppStats {
  final int totalAnimales;
  final int adopcionesPendientes;
  final int reportesActivos;
  final int usuariosRegistrados;

  AppStats({
    required this.totalAnimales,
    required this.adopcionesPendientes,
    required this.reportesActivos,
    required this.usuariosRegistrados,
  });
}

final statsMock = AppStats(
  totalAnimales: 124,
  adopcionesPendientes: 12,
  reportesActivos: 8,
  usuariosRegistrados: 450,
);
