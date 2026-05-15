import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../widgets/navbar.dart';
import '../../providers/puntos_provider.dart';

// Pantalla de recompensas y puntos del usuario
class MisPuntosScreen extends ConsumerWidget {
  const MisPuntosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;
    final puntos = ref.watch(puntosProvider).puntos;
    final nivel = ref.watch(nivelProvider);

    return Scaffold(
      backgroundColor: colores.surface,
      bottomNavigationBar: const NavbarPrincipal(indiceActual: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CabeceraRecompensas(puntos: puntos, nivel: nivel),
              _ProgresoNivel(puntos: puntos, nivel: nivel),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _SeccionComoGanarPuntos(colores: colores),
                    const SizedBox(height: 28),
                    _SeccionInsignias(colores: colores),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cabecera verde con boton volver y tarjeta de puntos
class _CabeceraRecompensas extends StatelessWidget {
  final int puntos;
  final NivelUsuario nivel;

  const _CabeceraRecompensas({required this.puntos, required this.nivel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: colorPrimario,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con titulo y trofeo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/perfil'),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: colorBlanco, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mis recompensas',
                    style: TextStyle(
                        color: colorBlanco,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorBlanco.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events_outlined,
                    color: colorBlanco, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Gana puntos participando en la comunidad',
            style: TextStyle(color: colorBlanco.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Tarjeta de puntos — igual que la del perfil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorBlanco.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('⭐ $puntos puntos',
                        style: const TextStyle(
                            color: colorBlanco,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(
                      nivel.siguiente != null
                          ? '→ ${nivel.siguiente!.puntosMinimos} para ${nivel.siguiente!.nombre.replaceFirst('Nivel ', '')}'
                          : '¡Nivel máximo!',
                      style: TextStyle(
                          color: colorBlanco.withValues(alpha: 0.8), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: calcularProgreso(puntos, nivel),
                    minHeight: 8,
                    backgroundColor: colorBlanco.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(colorAcento),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${nivel.emoji} ${nivel.nombre}',
                    style: TextStyle(
                        color: colorBlanco.withValues(alpha: 0.85), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Barra de progreso con los cuatro niveles
class _ProgresoNivel extends StatelessWidget {
  final int puntos;
  final NivelUsuario nivel;

  const _ProgresoNivel({required this.puntos, required this.nivel});

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;
    final colores = Theme.of(context).colorScheme;

    final colorBarraFondo = esModoOscuro
        ? colores.surfaceContainerLowest
        : const Color(0xFFE0E0E0);

    final siguiente = nivel.siguiente;
    final puntosRestantes =
        siguiente != null ? siguiente.puntosMinimos - puntos : 0;

    return Container(
      width: double.infinity,
      color: colores.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso de nivel',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: esModoOscuro ? Colors.white : colorTexto,
            ),
          ),
          const SizedBox(height: 16),
          // Iconos de los cuatro niveles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: NivelUsuario.values
                .map((n) => _IconoNivel(
                      emoji: n.emoji,
                      label: n.nombre.replaceFirst('Nivel ', ''),
                      activo: n == nivel,
                      esModoOscuro: esModoOscuro,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: calcularProgreso(puntos, nivel),
              minHeight: 10,
              backgroundColor: colorBarraFondo,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(height: 8),
          // Puntos actuales y cuantos faltan para el siguiente nivel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$puntos puntos',
                style: TextStyle(
                    fontSize: 12,
                    color: esModoOscuro ? Colors.white70 : colorTextoSuave),
              ),
              Text(
                siguiente != null
                    ? '$puntosRestantes para ${siguiente.nombre.replaceFirst('Nivel ', '')}'
                    : '¡Nivel máximo alcanzado!',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Icono circular de un nivel con su emoji y etiqueta
class _IconoNivel extends StatelessWidget {
  final String emoji;
  final String label;
  final bool activo;
  final bool esModoOscuro;

  const _IconoNivel({
    required this.emoji,
    required this.label,
    required this.activo,
    required this.esModoOscuro,
  });

  @override
  Widget build(BuildContext context) {
    final colorInactivo =
        esModoOscuro ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
    final colorLabelInactivo =
        esModoOscuro ? Colors.white54 : colorTextoSuave;

    return Column(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: activo
                ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                : colorInactivo,
            shape: BoxShape.circle,
            border: activo
                ? Border.all(color: const Color(0xFFF59E0B), width: 2)
                : null,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            color: activo ? const Color(0xFFF59E0B) : colorLabelInactivo,
          ),
        ),
      ],
    );
  }
}

// Seccion que explica como ganar puntos
class _SeccionComoGanarPuntos extends StatelessWidget {
  final ColorScheme colores;

  const _SeccionComoGanarPuntos({required this.colores});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Cómo ganar puntos?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colores.onSurface)),
        const SizedBox(height: 12),
        _FilaPuntos(
            emoji: '📢',
            texto: 'Reportar mascota perdida',
            puntos: '+100',
            color: colorPerdidas),
        const SizedBox(height: 8),
        _FilaPuntos(
            emoji: '❤️',
            texto: 'Solicitar adopción',
            puntos: '+100',
            color: colorError),
        const SizedBox(height: 8),
        _FilaPuntos(
            emoji: '🐾',
            texto: 'Ayudar a encontrar mascota',
            puntos: '+200',
            color: colorPrimario),
      ],
    );
  }
}

// Fila con emoji, descripcion y puntos que se ganan
class _FilaPuntos extends StatelessWidget {
  final String emoji;
  final String texto;
  final String puntos;
  final Color color;

  const _FilaPuntos({
    required this.emoji,
    required this.texto,
    required this.puntos,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texto,
                style: TextStyle(
                    fontSize: 14,
                    color: colores.onSurface,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(puntos,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// Seccion de insignias con grid
class _SeccionInsignias extends StatelessWidget {
  final ColorScheme colores;

  const _SeccionInsignias({required this.colores});

  // Lista de insignias hardcodeada
  static const List<_DatosInsignia> _insignias = [
    _DatosInsignia(
      emoji: '🐾',
      titulo: 'Primer Reporte',
      descripcion: 'Has reportado tu primera mascota perdida',
      tipo: 'Insignia',
      puntos: 50,
      desbloqueada: true,
    ),
    _DatosInsignia(
      emoji: '❤️',
      titulo: 'Adoptante Activo',
      descripcion: 'Has solicitado 3 adopciones',
      tipo: 'Insignia',
      puntos: 100,
      desbloqueada: true,
    ),
    _DatosInsignia(
      emoji: '🦸',
      titulo: 'Héroe Animal',
      descripcion: 'Ayudaste a encontrar 5 mascotas perdidas',
      tipo: 'Insignia',
      puntos: 200,
      desbloqueada: false,
    ),
    _DatosInsignia(
      emoji: '🛡️',
      titulo: 'Guardián Comunitario',
      descripcion: 'Participaste 10 veces en la búsqueda de mascotas',
      tipo: 'Insignia',
      puntos: 300,
      desbloqueada: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Insignias y premios',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colores.onSurface)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: _insignias
              .map((insignia) => _TarjetaInsignia(datos: insignia))
              .toList(),
        ),
      ],
    );
  }
}

// Datos de una insignia
class _DatosInsignia {
  final String emoji;
  final String titulo;
  final String descripcion;
  final String tipo;
  final int puntos;
  final bool desbloqueada;

  const _DatosInsignia({
    required this.emoji,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.puntos,
    required this.desbloqueada,
  });
}

// Tarjeta de una insignia, cambia estilo si esta bloqueada
class _TarjetaInsignia extends StatelessWidget {
  final _DatosInsignia datos;

  const _TarjetaInsignia({required this.datos});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    final colorTarjeta = datos.desbloqueada
        ? (esModoOscuro ? colores.surfaceContainerHigh : colorBlanco)
        : colores.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: datos.desbloqueada
              ? colorPrimario.withValues(alpha: 0.3)
              : colores.outlineVariant,
        ),
        boxShadow: datos.desbloqueada && !esModoOscuro
            ? [
                BoxShadow(
                  color: colorPrimario.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(datos.emoji, style: const TextStyle(fontSize: 28)),
              // Icono de check o candado segun si esta desbloqueada
              Icon(
                datos.desbloqueada ? Icons.check_circle : Icons.lock_outline,
                color: datos.desbloqueada ? colorReportar : colorTextoSuave,
                size: 18,
              ),
            ],
          ),
          const Spacer(),
          Text(
            datos.titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: datos.desbloqueada ? colores.onSurface : colorTextoSuave,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            datos.descripcion,
            style: TextStyle(
                fontSize: 10,
                color: esModoOscuro ? Colors.white54 : colorTextoSuave),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Chip del tipo de insignia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: datos.desbloqueada
                      ? colorPrimario.withValues(alpha: 0.1)
                      : (esModoOscuro
                          ? colores.surfaceContainerLowest
                          : const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  datos.tipo,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: datos.desbloqueada
                        ? colorPrimario
                        : (esModoOscuro ? Colors.white54 : colorTextoSuave),
                  ),
                ),
              ),
              const Spacer(),
              // Puntos que da la insignia
              Text(
                '⭐ ${datos.puntos}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: datos.desbloqueada
                      ? const Color(0xFFF59E0B)
                      : (esModoOscuro ? Colors.white38 : colorTextoSuave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}