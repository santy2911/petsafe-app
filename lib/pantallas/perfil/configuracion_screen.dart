import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';

// Pantalla de ajustes de la app
class ConfiguracionScreen extends ConsumerStatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  ConsumerState<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends ConsumerState<ConfiguracionScreen> {
  bool _notificacionesActivas = true;

  // Muestra un snackbar de exito o error
  void _mostrarConfirmacion(BuildContext context, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              exito ? Icons.check_circle_outline : Icons.error_outline,
              color: colorBlanco,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              exito ? 'Cambios guardados correctamente' : 'No se pudieron guardar los cambios',
              style: const TextStyle(color: colorBlanco, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: exito ? colorReportar : colorError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colores.surface,
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
        backgroundColor: colorPrimario,
        foregroundColor: colorBlanco,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/perfil'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _seccionPreferencias(),
          const SizedBox(height: 24),
          _seccionCuenta(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Ajustes de notificaciones y modo oscuro
  Widget _seccionPreferencias() {
    final modoOscuro = ref.watch(modoOscuroProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Seccion(titulo: 'Preferencias'),
        _GrupoTarjetas(
          items: [
            _ItemSwitch(
              icono: Icons.notifications_outlined,
              colorIcono: colorPrimario,
              fondoIcono: colorPrimario.withValues(alpha: 0.1),
              texto: 'Notificaciones push',
              valor: _notificacionesActivas,
              onCambio: (v) => setState(() => _notificacionesActivas = v),
            ),
            _ItemSwitch(
              icono: Icons.dark_mode_outlined,
              colorIcono: Colors.blue,
              fondoIcono: Colors.blue.withValues(alpha: 0.1),
              texto: 'Modo oscuro',
              valor: modoOscuro,
              onCambio: (v) => ref.read(modoOscuroProvider.notifier).state = v,
            ),
          ],
        ),
      ],
    );
  }

  // Opciones de cuenta del usuario
  Widget _seccionCuenta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Seccion(titulo: 'Cuenta'),
        _GrupoTarjetas(
          items: [
            _ItemAccion(
              icono: Icons.mail_outline,
              colorIcono: colorPrimario,
              fondoIcono: colorPrimario.withValues(alpha: 0.1),
              texto: 'Cambiar correo electrónico',
              subtexto: 'usuario@ejemplo.com',
              onTap: () => _mostrarCambiarEmail(context),
            ),
            _ItemAccion(
              icono: Icons.phone_outlined,
              colorIcono: colorReportar,
              fondoIcono: colorReportar.withValues(alpha: 0.1),
              texto: 'Teléfono',
              subtexto: '+34 612 345 678',
              onTap: () => _mostrarCambiarTelefono(context),
            ),
            _ItemAccion(
              icono: Icons.lock_outline,
              colorIcono: colorPerdidas,
              fondoIcono: colorPerdidas.withValues(alpha: 0.1),
              texto: 'Cambiar contraseña',
              onTap: () => _mostrarCambiarPassword(context),
            ),
            _ItemAccion(
              icono: Icons.delete_outline,
              colorIcono: colorError,
              fondoIcono: colorError.withValues(alpha: 0.1),
              texto: 'Eliminar cuenta',
              colorTexto: colorError,
              onTap: () => _mostrarConfirmacionEliminar(context),
            ),
          ],
        ),
      ],
    );
  }

  // Abre el modal para cambiar el email
  void _mostrarCambiarEmail(BuildContext context) {
    _mostrarModalAjuste(
      context: context,
      titulo: 'Cambiar correo electrónico',
      hijos: [
        _CampoTexto(
          controlador: TextEditingController(),
          etiqueta: 'Nuevo correo electrónico',
          tipo: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // Abre el modal para cambiar el telefono
  void _mostrarCambiarTelefono(BuildContext context) {
    _mostrarModalAjuste(
      context: context,
      titulo: 'Cambiar teléfono',
      hijos: [
        _CampoTexto(
          controlador: TextEditingController(),
          etiqueta: 'Nuevo número de teléfono',
          tipo: TextInputType.phone,
        ),
      ],
    );
  }

  // Abre el modal para cambiar la password
  void _mostrarCambiarPassword(BuildContext context) {
    _mostrarModalAjuste(
      context: context,
      titulo: 'Cambiar contraseña',
      hijos: [
        _CampoTexto(controlador: TextEditingController(), etiqueta: 'Contraseña actual', esPassword: true),
        const SizedBox(height: 12),
        _CampoTexto(controlador: TextEditingController(), etiqueta: 'Nueva contraseña', esPassword: true),
        const SizedBox(height: 12),
        _CampoTexto(controlador: TextEditingController(), etiqueta: 'Repetir nueva contraseña', esPassword: true),
      ],
    );
  }

  // Modal generico reutilizable para los ajustes de cuenta
  void _mostrarModalAjuste({
    required BuildContext context,
    required String titulo,
    required List<Widget> hijos,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...hijos,
            const SizedBox(height: 20),
            _BotonGuardar(
              onPressed: () {
                Navigator.pop(ctx);
                _mostrarConfirmacion(context, exito: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialogo de confirmacion antes de borrar la cuenta
  void _mostrarConfirmacionEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗑️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text('¿Eliminar cuenta?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Esta acción es permanente. Perderás todos tus datos y mascotas guardadas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colorTextoSuave),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar', style: TextStyle(color: colorTexto)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: colorError),
                    child: const Text('Eliminar', style: TextStyle(color: colorBlanco)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Titulo de seccion
class _Seccion extends StatelessWidget {
  final String titulo;
  const _Seccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorTextoSuave, letterSpacing: 1.1),
      ),
    );
  }
}

// Agrupa varios items dentro de una tarjeta con separadores
class _GrupoTarjetas extends StatelessWidget {
  final List<Widget> items;
  const _GrupoTarjetas({required this.items});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
          ]
        ],
      ),
    );
  }
}

// Item con interruptor on/off
class _ItemSwitch extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color fondoIcono;
  final String texto;
  final bool valor;
  final ValueChanged<bool> onCambio;

  const _ItemSwitch({
    required this.icono, required this.colorIcono, required this.fondoIcono,
    required this.texto, required this.valor, required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconoOpcion(icono: icono, colorIcono: colorIcono, fondoIcono: fondoIcono),
      title: Text(texto, style: const TextStyle(fontSize: 14)),
      trailing: Switch(
        value: valor,
        onChanged: onCambio,
        activeThumbColor: colorPrimario,
      ),
    );
  }
}

// Item que ejecuta una accion al pulsarlo
class _ItemAccion extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color fondoIcono;
  final String texto;
  final String? subtexto;
  final Color? colorTexto;
  final VoidCallback onTap;

  const _ItemAccion({
    required this.icono, required this.colorIcono, required this.fondoIcono,
    required this.texto, required this.onTap, this.subtexto, this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: _IconoOpcion(icono: icono, colorIcono: colorIcono, fondoIcono: fondoIcono),
      title: Text(texto, style: TextStyle(fontSize: 14, color: colorTexto ?? colores.onSurface)),
      subtitle: subtexto != null
          ? Text(subtexto!, style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.chevron_right, color: colorTexto ?? colores.onSurfaceVariant, size: 20),
    );
  }
}

// Icono con fondo redondeado
class _IconoOpcion extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color fondoIcono;

  const _IconoOpcion({required this.icono, required this.colorIcono, required this.fondoIcono});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: fondoIcono, borderRadius: BorderRadius.circular(10)),
      child: Icon(icono, color: colorIcono, size: 18),
    );
  }
}

// Campo de texto generico para los modales
class _CampoTexto extends StatelessWidget {
  final TextEditingController controlador;
  final String etiqueta;
  final TextInputType tipo;
  final bool esPassword;

  const _CampoTexto({
    required this.controlador,
    required this.etiqueta,
    this.tipo = TextInputType.text,
    this.esPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      keyboardType: tipo,
      obscureText: esPassword,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Boton de guardar reutilizable
class _BotonGuardar extends StatelessWidget {
  final VoidCallback onPressed;
  const _BotonGuardar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text('Guardar', style: TextStyle(color: colorBlanco)),
      ),
    );
  }
}