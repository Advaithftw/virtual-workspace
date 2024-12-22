const { verifyToken } = require('../config/jwtConfig');

module.exports = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) return res.status(403).send('Access denied');
  try {
    const decoded = verifyToken(token.split(' ')[1]);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).send('Invalid token');
  }
};
