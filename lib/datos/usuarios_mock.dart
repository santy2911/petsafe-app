import '../modelos/usuario.dart';

final usuariosMock = [
  Usuario(
    id: '1',
    nombre: 'Admin PetSafe',
    email: 'admin@petsafe.es',
    telefono: '600000001',
    rol: 'Admin',
    imagenUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Admin',
  ),
  Usuario(
    id: '2',
    nombre: 'Juan Pérez',
    email: 'juan@gmail.com',
    telefono: '600000002',
    rol: 'User',
    imagenUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Juan',
  ),
  Usuario(
    id: '3',
    nombre: 'María García',
    email: 'maria@outlook.com',
    telefono: '600000003',
    rol: 'User',
    imagenUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Maria',
  ),
];
