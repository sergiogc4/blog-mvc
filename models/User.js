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

// Sobreescriure el mètode hasPermission per assegurar que funciona
userSchema.methods.hasPermission = async function(permissionName) {
  const permissions = await this.getEffectivePermissions();
  return permissions.includes(permissionName);
};
