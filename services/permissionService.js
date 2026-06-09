const Role = require('../models/Role');

class PermissionService {
  async getRolePermissions(roleId) {
    const role = await Role.findById(roleId).populate('permissions');
    if (!role) return [];
    const permissions = [...role.permissions];
    if (role.parentRole) {
      const parentPermissions = await this.getRolePermissions(role.parentRole);
      permissions.push(...parentPermissions);
    }
    const unique = [];
    const ids = new Set();
    for (const p of permissions) {
      if (!ids.has(p._id.toString())) {
        ids.add(p._id.toString());
        unique.push(p);
      }
    }
    return unique;
  }

  async getRoleHierarchy(roleId) {
    const hierarchy = [];
    let currentRole = await Role.findById(roleId);
    while (currentRole) {
      hierarchy.push({ id: currentRole._id, name: currentRole.name, level: currentRole.level });
      currentRole = currentRole.parentRole ? await Role.findById(currentRole.parentRole) : null;
    }
    return hierarchy;
  }
}

module.exports = new PermissionService();
