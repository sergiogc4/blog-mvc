const Permission = require('../models/Permission');
const AuditLog = require('../models/AuditLog');

const getPermissions = async (req, res) => {
  try {
    const permissions = await Permission.find().sort({ category: 1, name: 1 });
    res.json({ success: true, data: permissions });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getPermissionById = async (req, res) => {
  try {
    const permission = await Permission.findById(req.params.id);
    if (!permission) return res.status(404).json({ success: false, error: 'Permís no trobat' });
    res.json({ success: true, data: permission });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const createPermission = async (req, res) => {
  try {
    const { name, description, category } = req.body;
    
    const existing = await Permission.findOne({ name: name.toLowerCase() });
    if (existing) {
      return res.status(400).json({ success: false, error: 'Permís duplicat' });
    }
    
    const permission = await Permission.create({
      name: name.toLowerCase(),
      description,
      category: category || 'general'
    });
    
    res.status(201).json({ success: true, data: permission });
  } catch (error) {
    console.error('Error crear permís:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

const updatePermission = async (req, res) => {
  try {
    const permission = await Permission.findById(req.params.id);
    if (!permission) return res.status(404).json({ success: false, error: 'Permís no trobat' });
    
    const { description, category } = req.body;
    if (description) permission.description = description;
    if (category) permission.category = category;
    await permission.save();
    
    res.json({ success: true, data: permission });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const deletePermission = async (req, res) => {
  try {
    const permission = await Permission.findById(req.params.id);
    if (!permission) return res.status(404).json({ success: false, error: 'Permís no trobat' });
    
    if (permission.isSystemPermission) {
      return res.status(403).json({ success: false, error: 'No pots eliminar un permís del sistema' });
    }
    
    await permission.deleteOne();
    res.json({ success: true, message: 'Permís eliminat' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { getPermissions, getPermissionById, createPermission, updatePermission, deletePermission };
