const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function fixAdminPassword() {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/task-manager-t9');
    console.log('✅ Connectat a MongoDB');

    const User = require('./models/User');
    const Role = require('./models/Role');

    // Buscar l'usuari admin
    let admin = await User.findOne({ email: 'admin@system.com' });
    const superAdminRole = await Role.findOne({ name: 'super_admin' });

    if (!admin) {
      // Si no existeix, crear-lo
      if (!superAdminRole) {
        console.log('❌ Error: No s'ha trobat el rol super_admin');
        process.exit(1);
      }
      const hashedPassword = await bcrypt.hash('Admin123!', 10);
      admin = await User.create({
        name: 'System Administrator',
        email: 'admin@system.com',
        password: hashedPassword,
        roles: [superAdminRole._id],
        isActive: true
      });
      console.log('✅ Usuari admin creat amb contrasenya Admin123!');
    } else {
      // Si existeix, actualitzar contrasenya
      const newHashedPassword = await bcrypt.hash('Admin123!', 10);
      admin.password = newHashedPassword;
      await admin.save();
      console.log('✅ Contrasenya de l'admin actualitzada a Admin123!');
    }

    console.log(`👤 Email: admin@system.com`);
    console.log(`🔑 Contrasenya: Admin123!`);
    await mongoose.connection.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

fixAdminPassword();
