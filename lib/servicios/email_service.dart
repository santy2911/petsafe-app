import 'dart:developer';

class EmailService {
  static Future<void> enviarEmail({
    required String destinatario,
    required String asunto,
    required String cuerpo,
  }) async {
    // Simulación de envío de email
    // En producción aquí iría una integración con SendGrid, Mailgun, etc.
    await Future.delayed(const Duration(seconds: 1));
    log('📧 EMAIL ENVIADO A: $destinatario');
    log('📝 ASUNTO: $asunto');
    log('📄 CUERPO: $cuerpo');
  }
}
