import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notificaciones_provider.dart';
import '../tema.dart';

class BotonNotificaciones extends ConsumerWidget {
  const BotonNotificaciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noLeidas = ref.watch(noLeidasProvider);

    return Stack(
      children: [
        IconButton(
          onPressed: () => context.go('/notificaciones'),
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notificaciones',
        ),
        if (noLeidas > 0)
          Positioned(
            right: 11,
            top: 11,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colorAcentoRosa,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
