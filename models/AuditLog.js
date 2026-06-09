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
