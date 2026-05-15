# Contexto del Proyecto PetSafe — Para el Agente de Antigravity

## ¿Qué es PetSafe?
PetSafe es una plataforma multiplataforma (web + app móvil) para centralizar la gestión de refugios de animales en España. Su objetivo es facilitar adopciones responsables y la localización de mascotas extraviadas. Es un TFG de DAM desarrollado por 5 alumnos con metodología Scrum.

**Stack tecnológico:**
*   **Backend:** Java con Spring Boot (API REST)
*   **App móvil:** Flutter / Kotlin
*   **Web:** Flutter Web (desplegada en Vercel → https://petsafe-one.vercel.app)

## Roles de usuario definidos
*   **Usuario ciudadano:** consulta animales, solicita adopciones, reporta mascotas perdidas, acumula puntos.
*   **Administrador de refugio:** gestiona animales, adopciones, usuarios y reportes desde el panel web.

## Lo que debe tener la plataforma WEB según el documento

### Panel de administración (Dashboard)
*   Sidebar lateral con navegación: Animales / Adopciones / Usuarios
*   Panel resumen con estadísticas en tiempo real:
    *   Total de animales en el sistema
    *   Adopciones pendientes
    *   Reportes activos de mascotas perdidas

### Gestión de Animales
*   Tabla con: nombre, edad, estado (disponible/adoptado)
*   Botón Añadir animal (formulario de registro)
*   Botones Editar y Eliminar por animal
*   Dar de baja a un animal (borrado lógico, no físico) — por adopción o fallecimiento

### Gestión de Adopciones
*   Lista de solicitudes con: usuario, animal, estado (pendiente / aceptada / rechazada)
*   Botones de acción: ✔ Aceptar / ✖ Rechazar / 👁 Ver detalle
*   Filtrado por estado
*   Al cambiar estado → notificación al usuario

### Gestión de Usuarios
*   Tabla con: nombre, email, rol (User / Admin)
*   Búsqueda de usuarios
*   Opciones de edición y gestión de roles

### Mapa de mascotas perdidas
*   Mapa en pantalla completa con marcadores interactivos (pins)
*   Popup con información al hacer clic en un marcador
*   Botón flotante para nuevo reporte

### Reportes de mascotas perdidas (vista web)
*   Visualización de reportes activos
*   Consulta de detalles de cada reporte
*   Actualización de estado: encontrada / no encontrada (borrado lógico)

### Autenticación
*   Login con email + contraseña
*   Registro de nuevos usuarios
*   Recuperación de contraseña por email
*   Sesión segura con JWT / tokens

### Sistema de puntos y recompensas
*   Los usuarios acumulan puntos por: publicar avisos, participar en búsquedas, reportar
*   El sistema valida la acción y actualiza el saldo automáticamente
*   Visible en el perfil del usuario

### Notificaciones
*   Notificaciones en tiempo real dentro de la app
*   Notificaciones por correo electrónico
*   Eventos que las disparan: animal perdido/encontrado, cambio de estado de adopción

## Requisitos funcionales clave (del documento)

| Código | Funcionalidad |
| :--- | :--- |
| **RF-01 a RF-04** | Registro, login, autenticación, recuperación de contraseña |
| **RF-05 a RF-09** | CRUD completo de animales + catálogo + detalle |
| **RF-10 a RF-12** | Solicitar adopción, gestionar solicitudes, cambiar estados |
| **RF-13 a RF-16** | Reportar mascota perdida con geolocalización, ver reportes, actualizar estado |

## Estado actual de la web (https://petsafe-one.vercel.app)
La web está desplegada en Vercel como Flutter Web.
*   Hay una base de frontend desarrollada con datos inventados (mocks)
*   No hay conexión real con el backend (la API REST en Spring Boot)
*   Faltan muchas pantallas y funcionalidades por implementar

## Lo que falta por implementar (a priorizar)
1.  **Conexión con la API REST (Spring Boot):** sin esto todo es estático.
2.  **Autenticación real:** login/registro/recuperación con JWT.
3.  **Panel admin funcional:** CRUD de animales, gestión de adopciones y usuarios con datos reales.
4.  **Mapa interactivo:** integración de geolocalización real en los reportes de mascotas perdidas.
5.  **Sistema de notificaciones:** tanto in-app como por email.
6.  **Sistema de recompensas:** lógica de puntos por acciones.
7.  **Gestión de estados de adopción:** flujo completo pendiente → aceptada/rechazada con notificación.
8.  **Borrado lógico de animales y reportes:** no eliminar físicamente de la BD.
9.  **Estadísticas del dashboard:** contadores reales desde la API.
10. **Roles y permisos:** separar vistas y acciones entre usuario ciudadano y admin de refugio.
