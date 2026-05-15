# Historial de Cambios — Proyecto PetSafe

Este archivo registra cronológicamente las implementaciones y mejoras realizadas en la plataforma PetSafe.

## [2026-05-15] — Consolidación de Funcionalidad y Gestión de Estado

### 🔑 Autenticación y Usuarios
- **Historial y Recompensas en Perfil**: Rediseño de `PerfilScreen` para incluir el historial de solicitudes de adopción, reportes de mascotas y un feed de actividad de puntos (RF-01, RF-58).
- **Gestión de Perfil (RF-01)**: Implementada la edición de perfil en `PerfilScreen`. Los usuarios ahora pueden actualizar su nombre y teléfono, con persistencia en el estado global.
- **Cierre de Sesión Seguro**: El botón de logout ahora limpia correctamente el estado del proveedor y navega automáticamente al login.
- **Detalle de Animal (AnimalDetalleScreen)**: Implementada la pantalla de detalle con galería de imágenes, animaciones Hero, información de salud y flujo de solicitud de adopción mediante BottomSheet (RF-21, RF-22).
- **Registro de Usuarios**: Implementado el flujo completo en `RegistroScreen`, conectado al `authProvider`. Ahora los nuevos usuarios pueden registrarse e iniciar sesión automáticamente.
- **Recuperación de Contraseña**: Finalizada la `RecuperarPasswordScreen` con lógica de envío de enlace (mock) y manejo de estados de carga.
- **Gestión de Usuarios (Admin)**: Creado el `usuariosProvider` y la pantalla `AdminUsuariosScreen`. Permite filtrar por rol, ascender a Admin/degradar a User y eliminar cuentas.

### 🐾 Gestión de Animales
- **Borrado Lógico (Dar de Baja)**: Añadida la funcionalidad "Dar de baja" en `AdminAnimalesScreen`. Permite retirar animales del catálogo por motivos de "Adopción" o "Fallecimiento" sin eliminarlos físicamente de la base de datos (RF-08).
- **CRUD Administrativo**: Implementada la creación y edición de animales con formularios validados.

### 🏠 Adopciones
- **Flujo de Solicitudes**: Los ciudadanos pueden enviar solicitudes con comentarios. Los administradores pueden aceptar o rechazar solicitudes desde su panel.
- **Sistema de Notificaciones (RF-34)**: Nueva pantalla `NotificacionesScreen` con historial ordenado, iconos por tipo y estados de lectura.
- **Acceso Global**: Icono de campana con badge dinámico integrado en todas las pantallas principales para acceso rápido a alertas.
- **Navegación Inteligente**: Al pulsar una notificación, la app redirige automáticamente al detalle del animal o reporte relacionado.
- **Automatización**: Notificaciones generadas automáticamente por eventos del sistema (adopciones aceptadas, mascotas encontradas, cambios administrativos).
- **Notificaciones Automáticas**: Al cambiar el estado de una adopción (Aceptada/Rechazada), se genera automáticamente una notificación interna para el usuario solicitante.

### 📍 Mascotas Perdidas y Mapa
- **Sistema de Recompensas (RF-58)**: Nueva pantalla `RecompensasScreen` con niveles (Bronce, Plata, Oro), ranking de usuarios y guía de obtención de puntos.
- **Gamificación**: Implementado sistema de niveles con barras de progreso animadas y medallas (🥇🥈🥉) según el desempeño del usuario.
- **Mapa Interactivo**: Integración de `flutter_map` con OpenStreetMap. Los reportes se visualizan con marcadores de colores según su estado (Perdido/Encontrado).
- **Sistema de Recompensas**: Implementada la lógica de puntos (RF-58). Los usuarios reciben **50 puntos** automáticamente al publicar un reporte de mascota perdida y **100 puntos** al marcarla como encontrada.
- **Geolocalización Real**: Integrado el paquete `geolocator` en el formulario de reporte. Permite obtener coordenadas exactas mediante GPS con manejo de permisos y previsualización en mini mapa.
- **Popups Interactivos en Mapa**: Implementados popups personalizados que aparecen al tocar un marcador, mostrando información rápida y acceso directo al detalle sin salir del mapa.
- **Detalle de Reporte (ReporteDetalleScreen)**: Nueva pantalla con mini mapa integrado, información del autor y gestión de estado (Perdido/Encontrado) con banners visuales. Accesible desde marcadores del mapa y desde el perfil del usuario.
- **Interconectividad**: Añadido botón "Ver Detalle Completo" en los popups del mapa y enlaces directos en la lista de reportes del perfil.
- **Reportar Pérdida**: Formulario funcional con selector de imágenes y geolocalización real integrada.

### 📊 Dashboard Administrativo
- **Estadísticas en Tiempo Real**: El panel principal ahora muestra contadores dinámicos de Animales Disponibles, Adopciones Pendientes y Reportes Activos, consumiendo datos directamente de los providers.
- **Actividad Reciente**: Feed dinámico que muestra las últimas solicitudes y reportes realizados en la plataforma.

### 🏗️ Arquitectura y UX
- **Gestión de Estados**: Implementados widgets globales para `LoadingState` (con efecto shimmer), `EmptyState` y `ErrorState` para una experiencia consistente.
- **Resiliencia**: Los proveedores ahora manejan reintentos y estados de carga realistas con simulaciones de latencia de red.
- **Validación Robusta**: Formularios de registro y reporte actualizados con validaciones en tiempo real y mensajes de error claros.
- **Notificaciones por Email (RF-64)**: Creado el `EmailService` para simular el envío de correos electrónicos.
- **Histórico de Bajas (Admin)**: Nueva pantalla `AdminHistoricoBajasScreen` que permite visualizar el registro de animales adoptados o fallecidos, manteniendo la trazabilidad del refugio.
- **Riverpod**: Migración total de mocks estáticos a `StateNotifierProviders` para una reactividad real.
- **GoRouter**: Configuración de rutas protegidas y navegación basada en roles (Admin/Ciudadano).
- **Diseño Premium**: Implementación de un sistema de diseño consistente basado en `tema.dart`, con micro-animaciones, sombras suaves y componentes altamente responsivos.

### 🐞 Correcciones de Errores
- **PerfilScreen**: Corregido error de compilación por falta de importación del `authProvider`.
- **HomeScreen**: Corregido error de compilación al acceder a la propiedad `usuarioActual` del `authProvider`.

---
*Nota: Este archivo debe actualizarse después de cada sesión de trabajo o cambio significativo.*
