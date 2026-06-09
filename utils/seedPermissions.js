const mongoose = require('mongoose');
const Permission = require('../models/Permission');
require('dotenv').config();

const permissions = [
  { name: 'tasks:read', description: 'Veure tasques', category: 'tasks' },
  { name: 'tasks:read_own', description: 'Veure pròpies tasques', category: 'tasks' },
  { name: 'tasks:create', description: 'Crear tasques', category: 'tasks' },
  { name: 'tasks:update', description: 'Actualitzar tasques', category: 'tasks' },
  { name: 'tasks:update_own', description: 'Actualitzar pròpies', category: 'tasks' },
  { name: 'tasks:delete', description: 'Eliminar', category: 'tasks' },
  { name: 'tasks:assign', description: 'Assignar', category: 'tasks' },
  { name: 'tasks:review', description: 'Revisar', category: 'tasks' },
  { name: 'users:read', description: 'Veure usuaris', category: 'users' },
  { name: 'users:manage', description: 'Gestionar', category: 'users' },
  { name: 'roles:read', description: 'Veure rols', category: 'roles' },
  { name: 'roles:manage', description: 'Gestionar rols', category: 'roles' },
  { name: 'permissions:read', description: 'Veure permisos', category: 'permissions' },
  { name: 'permissions:manage', description: 'Gestionar', category: 'permissions' },
  { name: 'audit:read', description: 'Veure logs', category: 'audit' },
  { name: 'system:configure', description: 'Configurar', category: 'system' },
  { name: 'system:backup', description: 'Backups', category: 'system' }
];

async function seedPermissions() {
  for (const perm of permissions) {
    const existing = await Permission.findOne({ name: perm.name });
    if (!existing) { 
      await Permission.create(perm); 
      console.log('✅', perm.name); 
    }
  }
  console.log('🎉 Permisos creats');
}

if (require.main === module) {
  mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/task-manager-t9')
    .then(async () => {
      await seedPermissions();
      await mongoose.connection.close();
      console.log('🔌 Connexió tancada');
    })
    .catch(err => console.error('Error:', err));
}

module.exports = seedPermissions;
