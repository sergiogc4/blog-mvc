const User = require('../models/User');
const AuditLog = require('../models/AuditLog');

const checkPermission = (permissionName) => {
  return async (req, res, next) => {
    const startTime = Date.now();
    
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, error: 'No autenticat' });
      }
      
      const user = await User.findById(req.user._id);
      const hasPermission = await user.hasPermission(permissionName);
      
      if (!hasPermission) {
        await AuditLog.log({
          userId: req.user._id,
          userName: req.user.name,
          action: permissionName,
          resource: req.path,
          resourceType: 'system',
          status: 'error',
          errorMessage: 'Permission denied',
          ipAddress: req.ip,
          userAgent: req.get('user-agent'),
          duration: Date.now() - startTime
        });
        
        return res.status(403).json({
          success: false,
          error: `No tens permís per: ${permissionName}`,
          requiredPermission: permissionName
        });
      }
      
      next();
    } catch (error) {
      console.error('Error a checkPermission:', error);
      res.status(500).json({ success: false, error: 'Error intern del servidor' });
    }
  };
};

module.exports = checkPermission;
