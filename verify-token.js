const jwt = require('jsonwebtoken');
require('dotenv').config();

const token = process.argv[2];
if (!token) {
  console.error('Uso: node verify-token.js <token>');
  process.exit(1);
}

const secret = process.env.JWT_SECRET || 'your-secret-key-change-me';
console.log('🔑 Secreto usado para verificar:', secret.substring(0, 10) + '...');
try {
  const decoded = jwt.verify(token, secret);
  console.log('✅ Token VÁLIDO');
  console.log('   Usuario:', decoded.userId);
  console.log('   Expira:', new Date(decoded.exp * 1000).toLocaleString());
} catch(e) {
  console.error('❌ Error:', e.message);
}
