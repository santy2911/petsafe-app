import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../providers/animales_provider.dart';
import '../../widgets/boton_notificaciones.dart';

class AdminHistoricoBajasScreen extends ConsumerWidget {
  const AdminHistoricoBajasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(animalesProvider);
    final bajas = state.animales
        .where((a) => a.estado == 'Adoptado' || a.estado == 'Fallecido')
        .toList();

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Histórico de Bajas'),
        actions: const [
          BotonNotificaciones(),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, color: colorTextoSuave),
                const SizedBox(width: 12),
                const Text(
                  'Registro histórico de animales que han pasado por el refugio.',
                  style: TextStyle(color: colorTextoSuave),
                ),
              ],
            ),
          ),
          if (bajas.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No hay registros de bajas aún.'),
              ),
            )
          else
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                decoration: decorationSuperficieLista(),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 60,
                    headingRowColor: WidgetStateProperty.all(colorFondo),
                    columns: const [
                      DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Especie', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Motivo de Baja', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Refugio', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: bajas.map((animal) {
                      return DataRow(cells: [
                        DataCell(Text(animal.nombre)),
                        DataCell(Text(animal.especie)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: animal.estado == 'Adoptado' 
                                  ? Colors.blue.withValues(alpha: 0.1) 
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              animal.estado,
                              style: TextStyle(
                                color: animal.estado == 'Adoptado' ? Colors.blue : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(animal.refugio)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
