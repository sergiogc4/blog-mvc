const rateLimit = require('express-rate-limit');

const roleLimits = { super_admin: 1000, admin: 500, manager: 200, user: 100, viewer: 50 };

const rateLimiter = (getRoleName) => rateLimit({
  windowMs: 60 * 1000,
  limit: async (req) => {
    if (getRoleName && req.user) {
      const roleName = req.user.roles?.[0]?.name || 'user';
      return roleLimits[roleName?.toLowerCase()] || 100;
    }
    return 100;
  },
  message: { success: false, error: 'Massa peticions' }
});

module.exports = { rateLimiter, roleLimits };
