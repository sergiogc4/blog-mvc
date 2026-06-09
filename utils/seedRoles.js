const mongoose = require('mongoose');
const Role = require('../models/Role');
const Permission = require('../models/Permission');
require('dotenv').config();

async function seedRoles() {
  const perms = await Permission.find();
  const permMap = {};
  perms.forEach(p => { permMap[p.name] = p._id; });
  
  let viewer = await Role.findOne({ name: 'viewer' });
  if (!viewer) {
    viewer = await Role.create({ 
      name: 'viewer', level: 1, parentRole: null,
      permissions: [permMap['tasks:read'], permMap['tasks:read_own']].filter(p => p), 
      description: 'Visualitzador', isSystemRole: true 
    });
    console.log('✅ Rol viewer creat');
  }
  
  let user = await Role.findOne({ name: 'user' });
  if (!user) {
    user = await Role.create({ 
      name: 'user', level: 2, parentRole: viewer._id,
      permissions: [permMap['tasks:create'], permMap['tasks:update_own']].filter(p => p), 
      description: 'Usuari', isSystemRole: true 
    });
    console.log('✅ Rol user creat');
  }
  
  let manager = await Role.findOne({ name: 'manager' });
  if (!manager) {
    manager = await Role.create({ 
      name: 'manager', level: 3, parentRole: user._id,
      permissions: [permMap['tasks:assign'], permMap['tasks:review'], permMap['users:read']].filter(p => p), 
      description: 'Manager', isSystemRole: true 
    });
    console.log('✅ Rol manager creat');
  }
  
  let admin = await Role.findOne({ name: 'admin' });
  if (!admin) {
    admin = await Role.create({ 
      name: 'admin', level: 4, parentRole: manager._id,
      permissions: [permMap['users:manage'], permMap['roles:manage'], permMap['audit:read']].filter(p => p), 
      description: 'Admin', isSystemRole: true 
    });
    console.log('✅ Rol admin creat');
  }
  
  let superAdmin = await Role.findOne({ name: 'super_admin' });
  if (!superAdmin) {
    superAdmin = await Role.create({ 
      name: 'super_admin', level: 5, parentRole: admin._id,
      permissions: [permMap['system:configure'], permMap['system:backup']].filter(p => p), 
      description: 'Super Admin', isSystemRole: true 
    });
    console.log('✅ Rol super_admin creat');
  }
  
  console.log('🎉 Rols creats amb jerarquia');
  console.log('   Jerarquia: SUPER_ADMIN(5) → ADMIN(4) → MANAGER(3) → USER(2) → VIEWER(1)');
}

if (require.main === module) {
  mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/task-manager-t9')
    .then(async () => {
      await seedRoles();
      await mongoose.connection.close();
      console.log('🔌 Connexió tancada');
    })
    .catch(err => console.error('Error:', err));
}

module.exports = seedRoles;
