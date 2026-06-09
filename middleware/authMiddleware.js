const jwtService = require('../services/jwtService');
const User = require('../models/User');

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, error: 'Token no proporcionat' });
    }
    
    const token = authHeader.split(' ')[1];
    
    // Comprovar si el token està a la blacklist
    const isRevoked = await jwtService.isTokenRevoked(token);
    if (isRevoked) {
      return res.status(401).json({ success: false, error: 'Token revocat' });
    }
    
    // Verificar token
    const decoded = jwtService.verifyAccessToken(token);
    if (!decoded) {
      return res.status(401).json({ success: false, error: 'Token invàlid o expirat' });
    }
    
    // Obtenir usuari amb els seus rols poblats
    const user = await User.findById(decoded.userId).populate('roles');
    if (!user || !user.isActive) {
      return res.status(401).json({ success: false, error: 'Usuari no trobat o inactiu' });
    }
    
    // Afegir informació de l'usuari a la request
    req.user = {
      _id: user._id,
      name: user.name,
      email: user.email,
      roles: user.roles
    };
    
    next();
  } catch (error) {
    console.error('Error a authMiddleware:', error);
    res.status(500).json({ success: false, error: 'Error intern del servidor' });
  }
};

module.exports = authMiddleware;
