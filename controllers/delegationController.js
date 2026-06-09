const DelegatedPermission = require('../models/DelegatedPermission');
const Permission = require('../models/Permission');
const AuditLog = require('../models/AuditLog');

// Llistar delegacions
const getDelegations = async (req, res) => {
  try {
    const delegations = await DelegatedPermission.find()
      .populate('fromUserId', 'name email')
      .populate('toUserId', 'name email')
      .populate('permission');
    res.json({ success: true, data: delegations });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Obtenir delegació per ID
const getDelegationById = async (req, res) => {
  try {
    const delegation = await DelegatedPermission.findById(req.params.id)
      .populate('fromUserId', 'name email')
      .populate('toUserId', 'name email')
      .populate('permission');
    if (!delegation) return res.status(404).json({ success: false, error: 'Delegació no trobada' });
    res.json({ success: true, data: delegation });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Crear delegació
const createDelegation = async (req, res) => {
  const startTime = Date.now();
  try {
    const { toUserId, permission, reason, daysValid = 5 } = req.body;
    if (daysValid <= 0) return res.status(400).json({ success: false, error: 'Els dies han de ser positius' });
    
    const permissionDoc = await Permission.findOne({ name: permission });
    if (!permissionDoc) return res.status(404).json({ success: false, error: 'Permís no trobat' });
    
    const delegation = await DelegatedPermission.create({
      fromUserId: req.user._id,
      toUserId,
      permission: permissionDoc._id,
      reason: reason || 'Delegació temporal',
      expiresAt: new Date(Date.now() + daysValid * 24 * 60 * 60 * 1000)
    });
    
    await AuditLog.log({
      userId: req.user._id, userName: req.user.name, action: 'delegation:create',
      resource: delegation._id, resourceType: 'delegation', status: 'success',
      changes: { toUserId, permission, daysValid }, ipAddress: req.ip,
      userAgent: req.get('user-agent'), duration: Date.now() - startTime
    });
    
    res.status(201).json({ success: true, data: delegation });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Revocar delegació
const revokeDelegation = async (req, res) => {
  const startTime = Date.now();
  try {
    const delegation = await DelegatedPermission.findById(req.params.id);
    if (!delegation) return res.status(404).json({ success: false, error: 'Delegació no trobada' });
    
    delegation.status = 'revoked';
    delegation.revokedAt = new Date();
    await delegation.save();
    
    await AuditLog.log({
      userId: req.user._id, userName: req.user.name, action: 'delegation:revoke',
      resource: delegation._id, resourceType: 'delegation', status: 'success',
      ipAddress: req.ip, userAgent: req.get('user-agent'), duration: Date.now() - startTime
    });
    
    res.json({ success: true, message: 'Delegació revocada' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Obtenir delegacions d'un usuari
const getUserDelegations = async (req, res) => {
  try {
    const delegations = await DelegatedPermission.find({ toUserId: req.params.userId })
      .populate('fromUserId', 'name email')
      .populate('permission');
    res.json({ success: true, data: delegations });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { getDelegations, getDelegationById, createDelegation, revokeDelegation, getUserDelegations };
