import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../providers/puntos_provider.dart';
import '../../providers/auth_provider.dart';

class RecompensasScreen extends ConsumerWidget {
  const RecompensasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puntosState = ref.watch(puntosProvider);
    final user = ref.watch(authProvider).usuarioActual;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Recompensas y Puntos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSaldoCard(puntosState.puntos, ref),
            const SizedBox(height: 32),
            _buildSectionTitle('¿Cómo ganar puntos?'),
            const SizedBox(height: 16),
            _buildWaysToEarn(),
            const SizedBox(height: 32),
            _buildSectionTitle('Ranking de la Comunidad'),
            const SizedBox(height: 16),
            _buildRanking(user?.nombre ?? 'Tú'),
            const SizedBox(height: 32),
            _buildSectionTitle('Historial de Actividad'),
            const SizedBox(height: 16),
            _buildHistorial(puntosState.historial),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoCard(int puntos, WidgetRef ref) {
    final nivel = ref.watch(nivelProvider);
    final progreso = calcularProgreso(puntos, nivel);
    final siguiente = nivel.siguiente;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colorXP, Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorXP.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Actual', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('$puntos XP', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                ],
              ),
              _TrophyIcon(emoji: nivel.emoji),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nivel.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (siguiente != null)
                Text('Siguiente: ${siguiente.nombre}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: 12,
                width: (progreso * 300), // Valor base simulado para web responsiva
                constraints: const BoxConstraints(minWidth: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 4)],
                ),
              ),
            ],
          ),
          if (siguiente != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Faltan ${siguiente.puntosMinimos - puntos} puntos para el nivel ${siguiente.nombre}',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaysToEarn() {
    final actions = [
      _ActionItem(icon: Icons.campaign_rounded, label: 'Publicar reporte mascota', points: '+50', color: colorPerdidas),
      _ActionItem(icon: Icons.check_circle_rounded, label: 'Mascota encontrada', points: '+100', color: colorReportar),
      _ActionItem(icon: Icons.favorite_rounded, label: 'Solicitar adopción', points: '+20', color: colorAdoptar),
      _ActionItem(icon: Icons.celebration_rounded, label: 'Adopción completada', points: '+150', color: colorAcento),
    ];

    return Column(children: actions);
  }

  Widget _buildHistorial(List<MovimientoPuntos> historial) {
    if (historial.isEmpty) {
      return const Center(child: Text('No hay movimientos registrados', style: TextStyle(color: colorTextoSuave)));
    }

    return Column(
      children: historial.map((m) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colorXPLight, shape: BoxShape.circle),
            child: const Icon(Icons.stars_rounded, color: colorXP, size: 20),
          ),
          title: Text(m.accion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(m.fecha.toString().split(' ')[0], style: const TextStyle(fontSize: 12)),
          trailing: Text('+${m.puntos} XP', style: const TextStyle(color: colorXP, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      )).toList(),
    );
  }

  Widget _buildRanking(String userName) {
    final topUsers = [
      _RankingUser(pos: 1, name: 'María G.', points: 1250, isCurrent: false),
      _RankingUser(pos: 2, name: 'Carlos R.', points: 980, isCurrent: false),
      _RankingUser(pos: 3, name: 'Ana S.', points: 750, isCurrent: false),
      _RankingUser(pos: 4, name: 'David L.', points: 620, isCurrent: false),
      _RankingUser(pos: 5, name: 'Lucía M.', points: 450, isCurrent: false),
    ];

    return Column(
      children: [
        ...topUsers.map((u) => _RankingTile(user: u)),
        const Divider(height: 32),
        _RankingTile(user: _RankingUser(pos: 12, name: userName, points: 175, isCurrent: true)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto));
  }
}

class _TrophyIcon extends StatefulWidget {
  final String emoji;
  const _TrophyIcon({required this.emoji});

  @override
  State<_TrophyIcon> createState() => _TrophyIconState();
}

class _TrophyIconState extends State<_TrophyIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
        child: Text(widget.emoji, style: const TextStyle(fontSize: 40)),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String points;
  final Color color;

  const _ActionItem({required this.icon, required this.label, required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colorBlanco, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            Text(points, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _RankingUser {
  final int pos;
  final String name;
  final int points;
  final bool isCurrent;
  _RankingUser({required this.pos, required this.name, required this.points, required this.isCurrent});
}

class _RankingTile extends StatelessWidget {
  final _RankingUser user;
  const _RankingTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: user.isCurrent ? colorXPLight : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: user.isCurrent ? Border.all(color: colorXP.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('#${user.pos}', style: TextStyle(fontWeight: FontWeight.bold, color: user.pos <= 3 ? colorAcento : colorTextoSuave))),
          CircleAvatar(radius: 18, backgroundColor: colorXPLight, child: Text(user.name[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorXP))),
          const SizedBox(width: 12),
          Expanded(child: Text(user.name, style: TextStyle(fontWeight: user.isCurrent ? FontWeight.bold : FontWeight.normal))),
          Text('${user.points} XP', style: const TextStyle(fontWeight: FontWeight.bold, color: colorTexto)),
        ],
      ),
    );
  }
}
