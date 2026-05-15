import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';

// Fondo uniforme de los iconos en esta pantalla (gris claro)
const Color _fondoIconoConfiguracion = Color(0xFFF1F5F9);

// Ancho máximo de los popups (compactos, centrados)
const double _anchoMaxPopupConfig = 360;

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
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/perfil'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          _seccionPreferencias(),
          const SizedBox(height: 32),
          _seccionCuenta(),
          const SizedBox(height: 40),
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
        const _TituloSeccion(titulo: 'Preferencias'),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _ItemSwitch(
                icono: Icons.notifications_outlined,
                colorIcono: colorPrimario,
                texto: 'Notificaciones push',
                valor: _notificacionesActivas,
                onCambio: (v) => setState(() => _notificacionesActivas = v),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _ItemSwitch(
                icono: Icons.dark_mode_outlined,
                colorIcono: colorXP,
                texto: 'Modo oscuro',
                valor: modoOscuro,
                onCambio: (v) => ref.read(modoOscuroProvider.notifier).state = v,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Opciones de cuenta del usuario
  Widget _seccionCuenta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloSeccion(titulo: 'Cuenta'),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _ItemAccion(
                icono: Icons.mail_outline_rounded,
                colorIcono: colorPrimario,
                texto: 'Cambiar correo electrónico',
                subtexto: 'usuario@ejemplo.com',
                onTap: () => _mostrarCambiarEmail(context),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _ItemAccion(
                icono: Icons.phone_outlined,
                colorIcono: colorPrimario,
                texto: 'Teléfono',
                subtexto: '+34 612 345 678',
                onTap: () => _mostrarCambiarTelefono(context),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _ItemAccion(
                icono: Icons.lock_outline_rounded,
                colorIcono: const Color(0xFF0A0A0A),
                texto: 'Cambiar contraseña',
                onTap: () => _mostrarCambiarPassword(context),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _ItemAccion(
                icono: Icons.delete_outline_rounded,
                colorIcono: colorError,
                texto: 'Eliminar cuenta',
                onTap: () => _mostrarConfirmacionEliminar(context),
              ),
            ],
          ),
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

  // Popup centrado reutilizable para los ajustes de cuenta
  void _mostrarModalAjuste({
    required BuildContext context,
    required String titulo,
    required List<Widget> hijos,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final teclado = MediaQuery.viewInsetsOf(ctx).bottom;
        return Dialog(
          backgroundColor: colorBlanco,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _anchoMaxPopupConfig),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + teclado),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto),
                    ),
                    const SizedBox(height: 16),
                    ...hijos,
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorTexto,
                                side: BorderSide(color: colorTexto.withValues(alpha: 0.12)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                minimumSize: const Size(0, 48),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _mostrarConfirmacion(context, exito: true);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                minimumSize: const Size(0, 48),
                              ),
                              child: const Text('Guardar'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogo de confirmacion antes de borrar la cuenta
  void _mostrarConfirmacionEliminar(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colorBlanco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _anchoMaxPopupConfig),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🗑️', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 12),
                const Text(
                  '¿Eliminar cuenta?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esta acción es permanente. Perderás todos tus datos y mascotas guardadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colorTextoSuave),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorTexto,
                            side: BorderSide(color: colorTexto.withValues(alpha: 0.12)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Cancelar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.go('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Titulo de seccion (mismo estilo que perfil)
class _TituloSeccion extends StatelessWidget {
  final String titulo;
  const _TituloSeccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto),
    );
  }
}

// Item con interruptor on/off
class _ItemSwitch extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String texto;
  final bool valor;
  final ValueChanged<bool> onCambio;

  const _ItemSwitch({
    required this.icono,
    required this.colorIcono,
    required this.texto,
    required this.valor,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: _IconoOpcion(icono: icono, colorIcono: colorIcono),
        title: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorTexto),
        ),
        trailing: Switch(
          value: valor,
          onChanged: onCambio,
          activeThumbColor: colorPrimario,
        ),
      ),
    );
  }
}

// Item que ejecuta una accion al pulsarlo
class _ItemAccion extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String texto;
  final String? subtexto;
  final VoidCallback onTap;

  const _ItemAccion({
    required this.icono,
    required this.colorIcono,
    required this.texto,
    required this.onTap,
    this.subtexto,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: _IconoOpcion(icono: icono, colorIcono: colorIcono),
        title: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorTexto),
        ),
        subtitle: subtexto != null
            ? Text(subtexto!, style: const TextStyle(fontSize: 13, color: colorTextoSuave))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: colorTextoSuave),
      ),
    );
  }
}

// Icono con fondo redondeado (mismo patron que perfil)
class _IconoOpcion extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;

  const _IconoOpcion({required this.icono, required this.colorIcono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _fondoIconoConfiguracion,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icono, color: colorIcono, size: 22),
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
      style: const TextStyle(fontSize: 15, color: colorTexto),
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: colorTextoSuave, fontSize: 15),
      ),
    );
  }
}
