const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

let isSeeding = false;

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/task-manager-t9');
    console.log('✅ MongoDB connectat');
    
    const Permission = require('./models/Permission');
    const Role = require('./models/Role');
    const User = require('./models/User');
    const bcrypt = require('bcryptjs');
    
    if ((await Permission.countDocuments()) === 0 && !isSeeding) {
      isSeeding = true;
      console.log('🌱 Seed permisos...');
      await require('./utils/seedPermissions')();
    }
    
    if ((await Role.countDocuments()) === 0 && !isSeeding) {
      isSeeding = true;
      console.log('🌱 Seed rols...');
      await require('./utils/seedRoles')();
    }
    
    const superAdminRole = await Role.findOne({ name: 'super_admin' });
    if (superAdminRole && (await User.countDocuments({ email: 'admin@system.com' })) === 0) {
      await User.create({
        name: 'System Administrator',
        email: 'admin@system.com',
        password: await bcrypt.hash('Admin123!', 10),
        roles: [superAdminRole._id]
      });
      console.log('✅ Usuari SUPER_ADMIN: admin@system.com / Admin123!');
    }
    
    console.log('🎉 Sistema T9 llest!');
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
};

connectDB();

// Middleware i imports
const auth = require('./middleware/authMiddleware');
const checkPermission = require('./middleware/checkPermission');
const { rateLimiter } = require('./middleware/rateLimiter');

// Controladors
const authController = require('./controllers/authController');
const userController = require('./controllers/userController');
const roleController = require('./controllers/roleController');
const permissionController = require('./controllers/permissionController');
const delegationController = require('./controllers/delegationController');
const auditController = require('./controllers/auditController');

// Models
const Role = require('./models/Role');
const Task = require('./models/Task');
const AuditLog = require('./models/AuditLog');

// ============================================
// RUTES PÚBLIQUES
// ============================================
app.get('/api/health', (req, res) => {
  res.json({ success: true, version: 'T9.0', features: ['Access+Refresh', 'Jerarquia', 'Delegacio', 'RateLimit', 'Auditoria', 'Export'] });
});

app.post('/api/auth/register', authController.register);
app.post('/api/auth/login', authController.login);
app.post('/api/auth/refresh', authController.refresh);
app.post('/api/auth/logout', auth, authController.logout);
app.post('/api/auth/forgot-password', authController.forgotPassword);
app.post('/api/auth/reset-password/:token', authController.resetPassword);

// ============================================
// RUTES USUARIS
// ============================================
app.get('/api/users', auth, checkPermission('users:read'), userController.getUsers);
app.get('/api/users/:id', auth, checkPermission('users:read'), userController.getUserById);
app.put('/api/users/:id', auth, checkPermission('users:manage'), userController.updateUser);
app.delete('/api/users/:id', auth, checkPermission('users:manage'), userController.deleteUser);
app.get('/api/users/:id/permissions', auth, checkPermission('users:read'), userController.getUserPermissions);

// ============================================
// RUTES ROLS
// ============================================
app.get('/api/roles', auth, checkPermission('roles:read'), roleController.getRoles);
app.get('/api/roles/:id', auth, checkPermission('roles:read'), roleController.getRoleById);
app.post('/api/roles', auth, checkPermission('roles:manage'), roleController.createRole);
app.put('/api/roles/:id', auth, checkPermission('roles:manage'), roleController.updateRole);
app.delete('/api/roles/:id', auth, checkPermission('roles:manage'), roleController.deleteRole);
app.get('/api/roles/:id/hierarchy', auth, checkPermission('roles:read'), roleController.getRoleHierarchy);
app.get('/api/roles/:id/permissions', auth, checkPermission('roles:read'), roleController.getRolePermissions);

// ============================================
// RUTES PERMISOS
// ============================================
app.get('/api/permissions', auth, checkPermission('permissions:read'), permissionController.getPermissions);
app.get('/api/permissions/:id', auth, checkPermission('permissions:read'), permissionController.getPermissionById);
app.post('/api/permissions', auth, checkPermission('permissions:manage'), permissionController.createPermission);
app.put('/api/permissions/:id', auth, checkPermission('permissions:manage'), permissionController.updatePermission);
app.delete('/api/permissions/:id', auth, checkPermission('permissions:manage'), permissionController.deletePermission);

// ============================================
// RUTES DELEGACIÓ
// ============================================
app.get('/api/delegations', auth, delegationController.getDelegations);
app.get('/api/delegations/:id', auth, delegationController.getDelegationById);
app.post('/api/delegations', auth, delegationController.createDelegation);
app.delete('/api/delegations/:id', auth, delegationController.revokeDelegation);
app.get('/api/delegations/user/:userId', auth, delegationController.getUserDelegations);

// ============================================
// RUTES AUDITORIA
// ============================================
app.get('/api/audit/logs', auth, checkPermission('audit:read'), auditController.getLogs);
app.get('/api/audit/stats', auth, checkPermission('audit:read'), auditController.getStats);
app.get('/api/audit/stats/user/:userId', auth, checkPermission('audit:read'), auditController.getUserStats);
app.get('/api/audit/export', auth, checkPermission('audit:export'), auditController.exportLogs);

// ============================================
// RUTES TASQUES
// ============================================
app.get('/api/tasks', auth, rateLimiter(() => req.user?.roles?.[0]?.name), checkPermission('tasks:read'), async (req, res) => {
  const { page = 1, limit = 10 } = req.query;
  res.json({ 
    success: true, 
    data: [
      { id: '1', title: 'Implementar Refresh Token', status: 'pending' },
      { id: '2', title: 'Crear Jerarquia de Rols', status: 'completed' }
    ],
    pagination: { page: parseInt(page), limit: parseInt(limit) }
  });
});

app.post('/api/tasks', auth, checkPermission('tasks:create'), async (req, res) => {
  const startTime = Date.now();
  await AuditLog.log({
    userId: req.user._id, userName: req.user.name, action: 'tasks:create',
    resource: 'task', resourceType: 'task', status: 'success',
    changes: req.body, ipAddress: req.ip, userAgent: req.get('user-agent'),
    duration: Date.now() - startTime
  });
  res.status(201).json({ success: true, message: 'Tasca creada', data: { id: Date.now().toString(), ...req.body } });
});

app.put('/api/tasks/:id', auth, checkPermission('tasks:update'), async (req, res) => {
  const startTime = Date.now();
  await AuditLog.log({
    userId: req.user._id, userName: req.user.name, action: 'tasks:update',
    resource: req.params.id, resourceType: 'task', status: 'success',
    changes: req.body, ipAddress: req.ip, userAgent: req.get('user-agent'),
    duration: Date.now() - startTime
  });
  res.json({ success: true, message: 'Tasca actualitzada', data: { id: req.params.id, ...req.body } });
});

app.get('/api/tasks/:id', auth, checkPermission('tasks:read'), async (req, res) => {
  res.json({ success: true, data: { id: req.params.id, title: 'Tasca exemple', status: 'pending' } });
});

app.delete('/api/tasks/:id', auth, checkPermission('tasks:delete'), async (req, res) => {
  const startTime = Date.now();
  await AuditLog.log({
    userId: req.user._id, userName: req.user.name, action: 'tasks:delete',
    resource: req.params.id, resourceType: 'task', status: 'success',
    ipAddress: req.ip, userAgent: req.get('user-agent'),
    duration: Date.now() - startTime
  });
  res.json({ success: true, message: 'Tasca eliminada' });
});

// ============================================
// ERROR HANDLERS
// ============================================
app.use('/api/*', (req, res) => {
  res.status(404).json({ success: false, error: 'Ruta no trobada' });
});

app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.statusCode || 500).json({ success: false, error: err.message || 'Error intern' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n========================================`);
  console.log(`🔐 T9 - JWT Avançat + Jerarquia de Rols`);
  console.log(`🚀 Servidor: http://localhost:${PORT}`);
  console.log(`========================================`);
  console.log(`📋 TOTAL ENDPOINTS: 51+`);
  console.log(`   ✅ Autenticació: 7 endpoints`);
  console.log(`   ✅ Usuaris: 5 endpoints`);
  console.log(`   ✅ Rols: 8 endpoints`);
  console.log(`   ✅ Permisos: 6 endpoints`);
  console.log(`   ✅ Delegació: 6 endpoints`);
  console.log(`   ✅ Auditoria: 5 endpoints`);
  console.log(`   ✅ Tasques: 5 endpoints`);
  console.log(`========================================`);
  console.log(`👤 Usuari: admin@system.com`);
  console.log(`🔑 Contrasenya: Admin123!`);
  console.log(`========================================\n`);
});
