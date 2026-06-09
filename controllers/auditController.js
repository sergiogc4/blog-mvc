const AuditLog = require('../models/AuditLog');
const mongoose = require('mongoose');

const getLogs = async (req, res) => {
  try {
    const { action, userId, limit = 50 } = req.query;
    const query = {};
    if (action) query.action = action;
    if (userId) query.userId = userId;
    
    const logs = await AuditLog.find(query)
      .sort({ timestamp: -1 })
      .limit(parseInt(limit))
      .populate('userId', 'name email');
    
    res.json({ success: true, data: logs });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getStats = async (req, res) => {
  try {
    const stats = await AuditLog.aggregate([
      { $group: { _id: '$action', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 20 }
    ]);
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getUserStats = async (req, res) => {
  try {
    const stats = await AuditLog.aggregate([
      { $match: { userId: new mongoose.Types.ObjectId(req.params.userId) } },
      { $group: { _id: '$action', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const exportLogs = async (req, res) => {
  try {
    const logs = await AuditLog.find().sort({ timestamp: -1 }).limit(1000);
    
    let csvContent = 'ID,Usuari,Acció,Recurs,Status,Timestamp,IP\n';
    for (const log of logs) {
      csvContent += `${log._id},${log.userName || log.userId},${log.action},${log.resource},${log.status},${log.timestamp},${log.ipAddress || ''}\n`;
    }
    
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=audit-logs.csv');
    res.send(csvContent);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { getLogs, getStats, getUserStats, exportLogs };
