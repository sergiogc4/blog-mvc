const jwt = require('jsonwebtoken');
const TokenBlacklist = require('../models/TokenBlacklist');

class JWTService {
  constructor() {
    this.accessTokenSecret = process.env.JWT_SECRET || 'your-secret-key-change-me';
    this.refreshTokenSecret = process.env.REFRESH_TOKEN_SECRET || 'your-refresh-secret-change-me';
    // Mostrar los primeros 10 caracteres del secreto para depuración
    console.log('🔐 JWT Access Secret (primeros 10 chars):', this.accessTokenSecret.substring(0, 10));
    console.log('🔐 JWT Refresh Secret (primeros 10 chars):', this.refreshTokenSecret.substring(0, 10));
  }

  generateAccessToken(userId, email, roleIds) {
    return jwt.sign(
      { userId, email, roles: roleIds, type: 'access' },
      this.accessTokenSecret,
      { expiresIn: '15m' }
    );
  }

  generateRefreshToken(userId) {
    return jwt.sign(
      { userId, type: 'refresh' },
      this.refreshTokenSecret,
      { expiresIn: '7d' }
    );
  }

  verifyAccessToken(token) {
    try {
      return jwt.verify(token, this.accessTokenSecret);
    } catch (error) {
      console.error('Error verificando access token:', error.message);
      return null;
    }
  }

  verifyRefreshToken(token) {
    try {
      return jwt.verify(token, this.refreshTokenSecret);
    } catch (error) {
      console.error('Error verificando refresh token:', error.message);
      return null;
    }
  }

  async revokeToken(token, userId, tokenType) {
    let expiresAt = tokenType === 'access'
      ? new Date(Date.now() + 15 * 60 * 1000)
      : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await TokenBlacklist.create({ token, userId, tokenType, expiresAt });
  }

  async isTokenRevoked(token) {
    const blacklisted = await TokenBlacklist.findOne({ token });
    return !!blacklisted;
  }
}

module.exports = new JWTService();
