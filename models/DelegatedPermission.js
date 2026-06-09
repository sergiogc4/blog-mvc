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
