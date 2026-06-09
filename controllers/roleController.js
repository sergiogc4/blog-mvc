const Role = require('../models/Role');
const Permission = require('../models/Permission');
const permissionService = require('../services/permissionService');

const getRoles = async (req, res) => {
  try {
    const roles = await Role.find().populate('permissions parentRole');
    res.json({ success: true, data: roles });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getRoleById = async (req, res) => {
  try {
    const role = await Role.findById(req.params.id).populate('permissions parentRole');
    if (!role) return res.status(404).json({ success: false, error: 'Rol no trobat' });
    res.json({ success: true, data: role });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const createRole = async (req, res) => {
  try {
    const { name, level, parentRole, permissions, description } = req.body;
    const existing = await Role.findOne({ name: name.toLowerCase() });
    if (existing) return res.status(400).json({ success: false, error: 'Rol duplicat' });
    
    const permissionIds = permissions ? await Permission.find({ name: { $in: permissions } }).then(p => p.map(p => p._id)) : [];
    const role = await Role.create({ name: name.toLowerCase(), level: level || 1, parentRole, permissions: permissionIds, description });
    await role.populate('permissions');
    res.status(201).json({ success: true, data: role });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const updateRole = async (req, res) => {
  try {
    const role = await Role.findById(req.params.id);
    if (!role) return res.status(404).json({ success: false, error: 'Rol no trobat' });
    if (role.isSystemRole) return res.status(403).json({ success: false, error: 'No pots modificar rol sistema' });
    
    const { description, permissions } = req.body;
    if (description) role.description = description;
    if (permissions) {
      const perms = await Permission.find({ name: { $in: permissions } });
      role.permissions = perms.map(p => p._id);
    }
    await role.save();
    res.json({ success: true, data: role });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const deleteRole = async (req, res) => {
  try {
    const role = await Role.findById(req.params.id);
    if (!role) return res.status(404).json({ success: false, error: 'Rol no trobat' });
    if (role.isSystemRole) return res.status(403).json({ success: false, error: 'No pots eliminar rol sistema' });
    await role.deleteOne();
    res.json({ success: true, message: 'Rol eliminat' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getRoleHierarchy = async (req, res) => {
  try {
    const hierarchy = await permissionService.getRoleHierarchy(req.params.id);
    res.json({ success: true, data: hierarchy });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getRolePermissions = async (req, res) => {
  try {
    const permissions = await permissionService.getRolePermissions(req.params.id);
    res.json({ success: true, data: permissions });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { getRoles, getRoleById, createRole, updateRole, deleteRole, getRoleHierarchy, getRolePermissions };
