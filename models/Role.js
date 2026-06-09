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
