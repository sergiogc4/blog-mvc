const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

async function deleteUser() {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/task-manager-t9');
    console.log('✅ Connectat a MongoDB');

    const email = 'joan@example.com';
    const result = await User.deleteOne({ email });

    if (result.deletedCount > 0) {
      console.log(`✅ Usuari amb email ${email} eliminat correctament.`);
    } else {
      console.log(`⚠️ No s'ha trobat cap usuari amb email ${email}.`);
    }

    await mongoose.connection.close();
    console.log('🔌 Connexió tancada');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

deleteUser();
