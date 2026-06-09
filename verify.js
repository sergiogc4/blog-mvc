const jwt = require('jsonwebtoken');
require('dotenv').config();

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2YTI1NTM2YTUzYTI2YTdkNWQwMmUxMjQiLCJlbWFpbCI6ImFkbWluQHN5c3RlbS5jb20iLCJyb2xlcyI6WyI2YTI1NTM2YTUzYTI2YTdkNWQwMmUxMjAiXSwidHlwZSI6ImFjY2VzcyIsImlhdCI6MTc4MTAzOTEzNCwiZXhwIjoxNzgxMDQwMDM0fQ.eTeAv_t4dRjKNQr5tMTpeHxiwCAw2nhjpPWGjzABoio';
const secret = process.env.JWT_SECRET || 'your-secret-key-change-me';

console.log('Secret used:', secret);
try {
  const decoded = jwt.verify(token, secret);
  console.log('✅ Token válido');
} catch(e) {
  console.error('❌ Error:', e.message);
}
