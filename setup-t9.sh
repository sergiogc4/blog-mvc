#!/bin/bash

echo "========================================="
echo "🔐 T9 - JWT Avançat + Jerarquia de Rols"
echo "========================================="

cd /home/sergio/node

# ============================================
# 1. CREAR NOUS MODELS
# ============================================

echo "📁 Creant models nous..."

# TokenBlacklist.js
cat > models/TokenBlacklist.js << 'EOF'
const mongoose = require('mongoose');

const tokenBlacklistSchema = new mongoose.Schema({
  token: { type: String, required: true, unique: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  tokenType: { type: String, enum: ['access', 'refresh'], required: true },
  revokedAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, required: true }
}, { timestamps: true });

tokenBlacklistSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('TokenBlacklist', tokenBlacklistSchema);
EOF

# DelegatedPermission.js
cat > models/DelegatedPermission.js << 'EOF'
const mongoose = require('mongoose');

const delegatedPermissionSchema = new mongoose.Schema({
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  toUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  permission: { type: mongoose.Schema.Types.ObjectId, ref: 'Permission', required: true },
  reason: { type: String, required: true },
  delegatedAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, required: true },
  revokedAt: { type: Date, default: null },
  status: { type: String, enum: ['active', 'expired', 'revoked'], default: 'active' }
}, { timestamps: true });

module.exports = mongoose.model('DelegatedPermission', delegatedPermissionSchema);
EOF

# PasswordReset.js
cat > models/PasswordReset.js << 'EOF'
const mongoose = require('mongoose');

const passwordResetSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  token: { type: String, required: true, unique: true },
  expiresAt: { type: Date, required: true },
  usedAt: { type: Date, default: null }
}, { timestamps: true });

passwordResetSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('PasswordReset', passwordResetSchema);
EOF

# Actualitzar Role.js
cat > models/Role.js << 'EOF'
const mongoose = require('mongoose');

const roleSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true, lowercase: true },
  level: { type: Number, required: true, min: 1, max: 5, default: 1 },
  parentRole: { type: mongoose.Schema.Types.ObjectId, ref: 'Role', default: null },
  permissions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Permission' }],
  description: { type: String, required: true },
  isSystemRole: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true }
}, { timestamps: true });

roleSchema.methods.getAllPermissions = async function() {
  const permissionsSet = new Set();
  this.permissions.forEach(perm => permissionsSet.add(perm.toString()));
  
  if (this.parentRole) {
    const parentRole = await mongoose.model('Role').findById(this.parentRole);
    if (parentRole) {
      const parentPermissions = await parentRole.getAllPermissions();
      parentPermissions.forEach(perm => permissionsSet.add(perm.toString()));
    }
  }
  return Array.from(permissionsSet);
};

module.exports = mongoose.model('Role', roleSchema);
EOF

# Actualitzar User.js
cat > models/User.js << 'EOF'
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  roles: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Role' }],
  isActive: { type: Boolean, default: true },
  lastLogin: { type: Date, default: null }
}, { timestamps: true });

userSchema.methods.getEffectivePermissions = async function() {
  const Permission = mongoose.model('Permission');
  const DelegatedPermission = mongoose.model('DelegatedPermission');
  const Role = mongoose.model('Role');
  
  const permissionsSet = new Set();
  
  for (const roleId of this.roles) {
    const role = await Role.findById(roleId);
    if (role) {
      const rolePermissions = await role.getAllPermissions();
      rolePermissions.forEach(perm => permissionsSet.add(perm.toString()));
    }
  }
  
  const activeDelegations = await DelegatedPermission.find({
    toUserId: this._id, status: 'active', expiresAt: { $gt: new Date() }
  }).populate('permission');
  
  activeDelegations.forEach(deleg => {
    if (deleg.permission) permissionsSet.add(deleg.permission._id.toString());
  });
  
  const permissions = await Permission.find({ _id: { $in: Array.from(permissionsSet) } });
  return permissions.map(p => p.name);
};

userSchema.methods.hasPermission = async function(permissionName) {
  const permissions = await this.getEffectivePermissions();
  return permissions.includes(permissionName);
};

userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
EOF

# AuditLog actualitzat
cat > models/AuditLog.js << 'EOF'
const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userName: { type: String },
  action: { type: String, required: true },
  resource: { type: String },
  resourceType: { type: String },
  status: { type: String, enum: ['success', 'error'], default: 'success' },
  changes: { type: mongoose.Schema.Types.Mixed, default: {} },
  errorMessage: { type: String },
  ipAddress: { type: String },
  userAgent: { type: String },
  duration: { type: Number, default: 0 }
}, { timestamps: { createdAt: 'timestamp', updatedAt: false } });

auditLogSchema.index({ userId: 1, timestamp: -1 });
auditLogSchema.index({ action: 1, timestamp: -1 });

auditLogSchema.statics.log = async function(data) { return this.create(data); };
auditLogSchema.statics.getStats = async function() {
  return this.aggregate([
    { $group: { _id: '$action', count: { $sum: 1 } } },
    { $sort: { count: -1 } }, { $limit: 10 }
  ]);
};

module.exports = mongoose.model('AuditLog', auditLogSchema);
EOF

# ============================================
# 2. CREAR SERVEIS
# ============================================

echo "📁 Creant serveis..."
mkdir -p services

cat > services/jwtService.js << 'EOF'
const jwt = require('jsonwebtoken');
const TokenBlacklist = require('../models/TokenBlacklist');

class JWTService {
  constructor() {
    this.accessTokenSecret = process.env.JWT_SECRET || 'your-secret-key';
    this.refreshTokenSecret = process.env.REFRESH_TOKEN_SECRET || 'your-refresh-secret';
    this.accessTokenExpiry = '15m';
    this.refreshTokenExpiry = '7d';
  }

  generateAccessToken(userId, email, roleIds) {
    return jwt.sign({ userId, email, roles: roleIds, type: 'access' }, this.accessTokenSecret, { expiresIn: this.accessTokenExpiry });
  }

  generateRefreshToken(userId) {
    return jwt.sign({ userId, type: 'refresh' }, this.refreshTokenSecret, { expiresIn: this.refreshTokenExpiry });
  }

  verifyAccessToken(token) {
    try { return jwt.verify(token, this.accessTokenSecret); } catch(e) { return null; }
  }

  verifyRefreshToken(token) {
    try { return jwt.verify(token, this.refreshTokenSecret); } catch(e) { return null; }
  }

  async revokeToken(token, userId, tokenType) {
    let expiresAt = tokenType === 'access' 
      ? new Date(Date.now() + 15 * 60 * 1000)
      : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await TokenBlacklist.create({ token, userId, tokenType, expiresAt });
  }

  async isTokenRevoked(token) {
    const blacklisted = await TokenBlacklist.findOne({ token });
    return !!blacklisted;
  }
}

module.exports = new JWTService();
EOF

cat > services/permissionService.js << 'EOF'
const Role = require('../models/Role');

class PermissionService {
  async getRolePermissions(roleId) {
    const role = await Role.findById(roleId).populate('permissions');
    if (!role) return [];
    const permissions = [...role.permissions];
    if (role.parentRole) {
      const parentPermissions = await this.getRolePermissions(role.parentRole);
      permissions.push(...parentPermissions);
    }
    const unique = [];
    const ids = new Set();
    for (const p of permissions) {
      if (!ids.has(p._id.toString())) {
        ids.add(p._id.toString());
        unique.push(p);
      }
    }
    return unique;
  }

  async getRoleHierarchy(roleId) {
    const hierarchy = [];
    let currentRole = await Role.findById(roleId);
    while (currentRole) {
      hierarchy.push({ id: currentRole._id, name: currentRole.name, level: currentRole.level });
      currentRole = currentRole.parentRole ? await Role.findById(currentRole.parentRole) : null;
    }
    return hierarchy;
  }
}

module.exports = new PermissionService();
EOF

# ============================================
# 3. CREAR MIDDLEWARE
# ============================================

echo "📁 Creant middleware..."

cat > middleware/authMiddleware.js << 'EOF'
const jwtService = require('../services/jwtService');
const User = require('../models/User');

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, error: 'Token no proporcionat' });
    }
    
    const token = authHeader.split(' ')[1];
    const isRevoked = await jwtService.isTokenRevoked(token);
    if (isRevoked) {
      return res.status(401).json({ success: false, error: 'Token revocat' });
    }
    
    const decoded = jwtService.verifyAccessToken(token);
    if (!decoded) {
      return res.status(401).json({ success: false, error: 'Token invàlid o expirat' });
    }
    
    const user = await User.findById(decoded.userId).populate('roles');
    if (!user || !user.isActive) {
      return res.status(401).json({ success: false, error: 'Usuari no trobat' });
    }
    
    req.user = { _id: user._id, name: user.name, email: user.email, roles: user.roles };
    next();
  } catch (error) {
    res.status(500).json({ success: false, error: 'Error intern' });
  }
};

module.exports = authMiddleware;
EOF

cat > middleware/rateLimiter.js << 'EOF'
const rateLimit = require('express-rate-limit');

const roleLimits = { super_admin: 1000, admin: 500, manager: 200, user: 100, viewer: 50 };

const rateLimiter = (getRoleName) => rateLimit({
  windowMs: 60 * 1000,
  limit: async (req) => {
    if (getRoleName && req.user) {
      const roleName = req.user.roles?.[0]?.name || 'user';
      return roleLimits[roleName?.toLowerCase()] || 100;
    }
    return 100;
  },
  message: { success: false, error: 'Massa peticions' }
});

module.exports = { rateLimiter, roleLimits };
EOF

cat > middleware/checkPermission.js << 'EOF'
const User = require('../models/User');
const AuditLog = require('../models/AuditLog');

const checkPermission = (permissionName) => {
  return async (req, res, next) => {
    try {
      if (!req.user) return res.status(401).json({ success: false, error: 'No autenticat' });
      
      const user = await User.findById(req.user._id);
      const hasPermission = await user.hasPermission(permissionName);
      
      if (!hasPermission) {
        await AuditLog.log({
          userId: req.user._id, userName: req.user.name, action: permissionName,
          resource: req.path, status: 'error', errorMessage: 'Permission denied',
          ipAddress: req.ip, userAgent: req.get('user-agent')
        });
        return res.status(403).json({ success: false, error: 'No tens permís' });
      }
      next();
    } catch (error) {
      res.status(500).json({ success: false, error: 'Error intern' });
    }
  };
};

module.exports = checkPermission;
EOF

# ============================================
# 4. CREAR CONTROLADORS
# ============================================

echo "📁 Creant controladors..."
mkdir -p controllers

cat > controllers/authController.js << 'EOF'
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const User = require('../models/User');
const Role = require('../models/Role');
const PasswordReset = require('../models/PasswordReset');
const jwtService = require('../services/jwtService');
const AuditLog = require('../models/AuditLog');

const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) return res.status(400).json({ success: false, error: 'Email invàlid' });
    if (password.length < 6) return res.status(400).json({ success: false, error: 'Contrasenya feble' });
    
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ success: false, error: 'Email duplicat' });
    
    const defaultRole = await Role.findOne({ name: 'viewer' });
    const salt = await bcrypt.genSalt(10);
    const user = await User.create({ name, email, password: await bcrypt.hash(password, salt), roles: [defaultRole._id] });
    
    const accessToken = jwtService.generateAccessToken(user._id, user.email, [defaultRole._id]);
    const refreshToken = jwtService.generateRefreshToken(user._id);
    
    res.status(201).json({ success: true, data: { user: { id: user._id, name, email }, accessToken, refreshToken, expiresIn: 900 } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email }).populate('roles');
    if (!user) return res.status(401).json({ success: false, error: 'Credencials invàlides' });
    
    const isValid = await user.comparePassword(password);
    if (!isValid) return res.status(401).json({ success: false, error: 'Credencials invàlides' });
    
    user.lastLogin = new Date(); await user.save();
    const roleIds = user.roles.map(r => r._id.toString());
    const accessToken = jwtService.generateAccessToken(user._id, user.email, roleIds);
    const refreshToken = jwtService.generateRefreshToken(user._id);
    
    res.json({ success: true, data: { user: { id: user._id, name: user.name, email, roles: user.roles.map(r => ({ name: r.name, level: r.level })) }, accessToken, refreshToken, expiresIn: 900 } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const refresh = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(400).json({ success: false, error: 'Refresh token requerit' });
    
    const isRevoked = await jwtService.isTokenRevoked(refreshToken);
    if (isRevoked) return res.status(401).json({ success: false, error: 'Token revocat' });
    
    const decoded = jwtService.verifyRefreshToken(refreshToken);
    if (!decoded) return res.status(401).json({ success: false, error: 'Token invàlid' });
    
    const user = await User.findById(decoded.userId).populate('roles');
    const roleIds = user.roles.map(r => r._id.toString());
    const newAccessToken = jwtService.generateAccessToken(user._id, user.email, roleIds);
    
    res.json({ success: true, accessToken: newAccessToken, expiresIn: 900 });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const logout = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    const { refreshToken } = req.body;
    const accessToken = authHeader?.split(' ')[1];
    
    if (accessToken) await jwtService.revokeToken(accessToken, req.user._id, 'access');
    if (refreshToken) await jwtService.revokeToken(refreshToken, req.user._id, 'refresh');
    
    res.json({ success: true, message: 'Sessió tancada' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.json({ success: true, message: 'Si existeix, rebràs un email' });
    
    const resetToken = crypto.randomBytes(32).toString('hex');
    await PasswordReset.create({ userId: user._id, token: resetToken, expiresAt: new Date(Date.now() + 3600000) });
    
    console.log('\n🔐 TOKEN RECUPERACIÓ:', resetToken, '\n');
    res.json({ success: true, message: 'Token enviat (veure consola)' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const resetPassword = async (req, res) => {
  try {
    const { token } = req.params;
    const { newPassword } = req.body;
    
    const resetRequest = await PasswordReset.findOne({ token, usedAt: null, expiresAt: { $gt: new Date() } });
    if (!resetRequest) return res.status(400).json({ success: false, error: 'Token invàlid' });
    
    const salt = await bcrypt.genSalt(10);
    await User.findByIdAndUpdate(resetRequest.userId, { password: await bcrypt.hash(newPassword, salt) });
    resetRequest.usedAt = new Date(); await resetRequest.save();
    
    res.json({ success: true, message: 'Contrasenya actualitzada' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { register, login, refresh, logout, forgotPassword, resetPassword };
EOF

cat > controllers/delegationController.js << 'EOF'
const DelegatedPermission = require('../models/DelegatedPermission');
const Permission = require('../models/Permission');
const AuditLog = require('../models/AuditLog');

const createDelegation = async (req, res) => {
  try {
    const { toUserId, permission, reason, daysValid = 5 } = req.body;
    if (daysValid <= 0) return res.status(400).json({ success: false, error: 'Dies invàlids' });
    
    const permissionDoc = await Permission.findOne({ name: permission });
    if (!permissionDoc) return res.status(404).json({ success: false, error: 'Permís no trobat' });
    
    const delegation = await DelegatedPermission.create({
      fromUserId: req.user._id, toUserId, permission: permissionDoc._id,
      reason, expiresAt: new Date(Date.now() + daysValid * 86400000)
    });
    
    res.status(201).json({ success: true, data: delegation });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getDelegations = async (req, res) => {
  const delegations = await DelegatedPermission.find().populate('fromUserId toUserId permission');
  res.json({ success: true, data: delegations });
};

const revokeDelegation = async (req, res) => {
  const delegation = await DelegatedPermission.findById(req.params.id);
  if (!delegation) return res.status(404).json({ success: false, error: 'No trobada' });
  delegation.status = 'revoked'; delegation.revokedAt = new Date(); await delegation.save();
  res.json({ success: true, message: 'Revocada' });
};

const getUserDelegations = async (req, res) => {
  const delegations = await DelegatedPermission.find({ toUserId: req.params.userId }).populate('fromUserId permission');
  res.json({ success: true, data: delegations });
};

module.exports = { createDelegation, getDelegations, revokeDelegation, getUserDelegations };
EOF

# ============================================
# 5. CREAR SCRIPTS DE SEED
# ============================================

echo "📁 Creant scripts de seed..."

cat > utils/seedPermissions.js << 'EOF'
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
  await mongoose.connect(process.env.MONGO_URI);
  for (const perm of permissions) {
    const existing = await Permission.findOne({ name: perm.name });
    if (!existing) { await Permission.create(perm); console.log('✅', perm.name); }
  }
  console.log('🎉 Permisos creats');
  mongoose.connection.close();
}

if (require.main === module) seedPermissions();
module.exports = seedPermissions;
EOF

cat > utils/seedRoles.js << 'EOF'
const mongoose = require('mongoose');
const Role = require('../models/Role');
const Permission = require('../models/Permission');
require('dotenv').config();

async function seedRoles() {
  await mongoose.connect(process.env.MONGO_URI);
  const perms = await Permission.find();
  const permMap = {};
  perms.forEach(p => { permMap[p.name] = p._id; });
  
  let viewer = await Role.findOne({ name: 'viewer' });
  if (!viewer) viewer = await Role.create({ name: 'viewer', level: 1, permissions: [permMap['tasks:read'], permMap['tasks:read_own']].filter(p => p), description: 'Visualitzador', isSystemRole: true });
  
  let user = await Role.findOne({ name: 'user' });
  if (!user) user = await Role.create({ name: 'user', level: 2, parentRole: viewer._id, permissions: [permMap['tasks:create'], permMap['tasks:update_own']].filter(p => p), description: 'Usuari', isSystemRole: true });
  
  let manager = await Role.findOne({ name: 'manager' });
  if (!manager) manager = await Role.create({ name: 'manager', level: 3, parentRole: user._id, permissions: [permMap['tasks:assign'], permMap['tasks:review'], permMap['users:read']].filter(p => p), description: 'Manager', isSystemRole: true });
  
  let admin = await Role.findOne({ name: 'admin' });
  if (!admin) admin = await Role.create({ name: 'admin', level: 4, parentRole: manager._id, permissions: [permMap['users:manage'], permMap['roles:manage'], permMap['audit:read']].filter(p => p), description: 'Admin', isSystemRole: true });
  
  let superAdmin = await Role.findOne({ name: 'super_admin' });
  if (!superAdmin) superAdmin = await Role.create({ name: 'super_admin', level: 5, parentRole: admin._id, permissions: [permMap['system:configure'], permMap['system:backup']].filter(p => p), description: 'Super Admin', isSystemRole: true });
  
  console.log('🎉 Rols creats amb jerarquia');
  mongoose.connection.close();
}

if (require.main === module) seedRoles();
module.exports = seedRoles;
EOF

# ============================================
# 6. CREAR NOU app.js
# ============================================

echo "📁 Creant app.js..."

cat > app.js << 'EOF'
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

const connectDB = async () => {
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/task-manager-t9');
  console.log('✅ MongoDB connectat');
  
  const Permission = require('./models/Permission');
  const Role = require('./models/Role');
  const User = require('./models/User');
  const bcrypt = require('bcryptjs');
  
  if ((await Permission.countDocuments()) === 0) {
    console.log('🌱 Seed permisos...');
    await require('./utils/seedPermissions')();
  }
  if ((await Role.countDocuments()) === 0) {
    console.log('🌱 Seed rols...');
    await require('./utils/seedRoles')();
  }
  
  const superAdminRole = await Role.findOne({ name: 'super_admin' });
  if (superAdminRole && (await User.countDocuments({ email: 'admin@system.com' })) === 0) {
    await User.create({
      name: 'System Admin', email: 'admin@system.com',
      password: await bcrypt.hash('Admin123!', 10), roles: [superAdminRole._id]
    });
    console.log('✅ Usuari admin creat: admin@system.com / Admin123!');
  }
};

connectDB();

const auth = require('./middleware/authMiddleware');
const checkPermission = require('./middleware/checkPermission');
const { rateLimiter } = require('./middleware/rateLimiter');
const authController = require('./controllers/authController');
const delegationController = require('./controllers/delegationController');
const permissionService = require('./services/permissionService');

// Rutes públiques
app.get('/api/health', (req, res) => res.json({ success: true, version: 'T9.0', features: ['Access+Refresh', 'Jerarquia', 'Delegacio', 'RateLimit', 'Auditoria'] }));
app.post('/api/auth/register', authController.register);
app.post('/api/auth/login', authController.login);
app.post('/api/auth/refresh', authController.refresh);
app.post('/api/auth/logout', auth, authController.logout);
app.post('/api/auth/forgot-password', authController.forgotPassword);
app.post('/api/auth/reset-password/:token', authController.resetPassword);

// Rols
app.get('/api/roles', auth, checkPermission('roles:read'), async (req, res) => {
  const roles = await Role.find().populate('permissions parentRole');
  res.json({ success: true, data: roles });
});
app.get('/api/roles/:id/hierarchy', auth, checkPermission('roles:read'), async (req, res) => {
  res.json({ success: true, data: await permissionService.getRoleHierarchy(req.params.id) });
});
app.get('/api/roles/:id/permissions', auth, checkPermission('roles:read'), async (req, res) => {
  res.json({ success: true, data: await permissionService.getRolePermissions(req.params.id) });
});

// Delegacions
app.get('/api/delegations', auth, delegationController.getDelegations);
app.post('/api/delegations', auth, delegationController.createDelegation);
app.delete('/api/delegations/:id', auth, delegationController.revokeDelegation);
app.get('/api/delegations/user/:userId', auth, delegationController.getUserDelegations);

// Tasques
app.get('/api/tasks', auth, rateLimiter(() => req.user?.roles?.[0]?.name), checkPermission('tasks:read'), async (req, res) => {
  res.json({ success: true, data: [{ id: '1', title: 'Tasca exemple T9' }] });
});

// Auditoria
app.get('/api/audit/logs', auth, checkPermission('audit:read'), async (req, res) => {
  const AuditLog = require('./models/AuditLog');
  const logs = await AuditLog.find().sort({ timestamp: -1 }).limit(50).populate('userId', 'name email');
  res.json({ success: true, data: logs });
});
app.get('/api/audit/stats', auth, checkPermission('audit:read'), async (req, res) => {
  const AuditLog = require('./models/AuditLog');
  res.json({ success: true, data: await AuditLog.getStats() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🔐 T9 - JWT Avançat funcionant a http://localhost:${PORT}`);
  console.log('👤 admin@system.com / Admin123!\n');
});
EOF

# ============================================
# 7. CREAR .env
# ============================================

cat > .env << 'EOF'
PORT=3000
MONGO_URI=mongodb://localhost:27017/task-manager-t9
JWT_SECRET=super-secret-key-t9-2024
REFRESH_TOKEN_SECRET=super-refresh-secret-t9-2024
EOF

# ============================================
# FINALITZAR
# ============================================

echo ""
echo "========================================="
echo "🎉 T9 IMPLEMENTAT COMPLETAMENT!"
echo "========================================="
echo ""
echo "🚀 Inicia el servidor amb:"
echo "   cd /home/sergio/node && npm run dev"
echo ""
echo "👤 Credencials: admin@system.com / Admin123!"
echo "========================================="
