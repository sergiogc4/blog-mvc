const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const User = require('../models/User');
const Role = require('../models/Role');
const PasswordReset = require('../models/PasswordReset');
const jwtService = require('../services/jwtService');
const AuditLog = require('../models/AuditLog');

const register = async (req, res) => {
  try {
    const { name, email, password, firstName, lastName } = req.body;
    const userName = name || `${firstName || ''} ${lastName || ''}`.trim() || email.split('@')[0];
    
    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      return res.status(400).json({ success: false, error: 'Email invàlid' });
    }
    if (!password || password.length < 6) {
      return res.status(400).json({ success: false, error: 'Contrasenya feble (mínim 6 caràcters)' });
    }
    
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ success: false, error: 'Email duplicat' });
    }
    
    const defaultRole = await Role.findOne({ name: 'viewer' });
    const salt = await bcrypt.genSalt(10);
    const user = await User.create({
      name: userName,
      email,
      password: await bcrypt.hash(password, salt),
      roles: defaultRole ? [defaultRole._id] : []
    });
    
    const accessToken = jwtService.generateAccessToken(user._id, user.email, user.roles.map(r => r.toString()));
    const refreshToken = jwtService.generateRefreshToken(user._id);
    
    res.status(201).json({
      success: true,
      data: {
        user: { id: user._id, name: user.name, email: user.email },
        accessToken,
        refreshToken,
        expiresIn: 900
      }
    });
  } catch (error) {
    console.error('Register error:', error);
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
    
    user.lastLogin = new Date();
    await user.save();
    
    const roleIds = user.roles.map(r => r._id.toString());
    const accessToken = jwtService.generateAccessToken(user._id, user.email, roleIds);
    const refreshToken = jwtService.generateRefreshToken(user._id);
    
    res.json({
      success: true,
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          roles: user.roles.map(r => ({ id: r._id, name: r.name, level: r.level }))
        },
        accessToken,
        refreshToken,
        expiresIn: 900
      }
    });
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
    if (!user) return res.status(401).json({ success: false, error: 'Usuari no trobat' });
    
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
    if (!user) {
      return res.json({ success: true, message: 'Si existeix, rebràs un email' });
    }
    
    const resetToken = crypto.randomBytes(32).toString('hex');
    await PasswordReset.create({
      userId: user._id,
      token: resetToken,
      expiresAt: new Date(Date.now() + 3600000)
    });
    
    console.log('\n🔐 TOKEN RECUPERACIÓ:', resetToken);
    console.log(`🔗 POST /api/auth/reset-password/${resetToken}\n`);
    
    res.json({ success: true, message: 'Token enviat (veure consola)', token: resetToken });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const resetPassword = async (req, res) => {
  try {
    const { token } = req.params;
    const { newPassword } = req.body;
    
    if (!newPassword || newPassword.length < 6) {
      return res.status(400).json({ success: false, error: 'Contrasenya feble' });
    }
    
    const resetRequest = await PasswordReset.findOne({
      token,
      usedAt: null,
      expiresAt: { $gt: new Date() }
    });
    
    if (!resetRequest) {
      return res.status(400).json({ success: false, error: 'Token invàlid o expirat' });
    }
    
    const salt = await bcrypt.genSalt(10);
    await User.findByIdAndUpdate(resetRequest.userId, {
      password: await bcrypt.hash(newPassword, salt)
    });
    
    resetRequest.usedAt = new Date();
    await resetRequest.save();
    
    res.json({ success: true, message: 'Contrasenya actualitzada' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { register, login, refresh, logout, forgotPassword, resetPassword };
