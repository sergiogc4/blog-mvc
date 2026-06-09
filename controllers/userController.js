const User = require('../models/User');
const AuditLog = require('../models/AuditLog');

const getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const users = await User.find().populate('roles').select('-password');
    res.json({ success: true, data: users });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).populate('roles').select('-password');
    if (!user) return res.status(404).json({ success: false, error: 'Usuari no trobat' });
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const updateUser = async (req, res) => {
  try {
    const { name, email, isActive } = req.body;
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, error: 'Usuari no trobat' });
    
    if (name) user.name = name;
    if (email) user.email = email;
    if (isActive !== undefined) user.isActive = isActive;
    await user.save();
    
    res.json({ success: true, message: 'Usuari actualitzat', data: user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, error: 'Usuari no trobat' });
    await user.deleteOne();
    res.json({ success: true, message: 'Usuari eliminat' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getUserPermissions = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).populate('roles');
    if (!user) return res.status(404).json({ success: false, error: 'Usuari no trobat' });
    const permissions = await user.getEffectivePermissions();
    res.json({ success: true, data: { userId: user._id, name: user.name, permissions } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { getUsers, getUserById, updateUser, deleteUser, getUserPermissions };
