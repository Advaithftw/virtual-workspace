const User = require('../models/User');
const bcrypt = require('bcryptjs');
const { generateToken } = require('../config/jwtConfig');

exports.signup = async (req, res) => {
  const { username, email, password } = req.body;

  try {
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'All fields are required: username, email, and password' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const newUser = new User({ username, email, password });
    const savedUser = await newUser.save();

    res.status(201).json({
      message: 'User created successfully',
      user: {
        username: savedUser.username,
        email: savedUser.email,
      },
    });
  } catch (error) {
    console.error('Error during signup:', error.message);
    res.status(500).json({ error: 'Failed to create user' });
  }
};

exports.login = async (req, res) => {
  const { username, email, password } = req.body;

  try {
    console.log('Login request received:', { username, email });

    if (!password || (!username && !email)) {
      console.warn('Login failed: Missing username/email or password');
      return res.status(400).json({ error: 'Username or email and password are required' });
    }

    const user = await User.findOne({ $or: [{ username }, { email }] });
    if (!user) {
      console.warn('Login failed: User not found');
      return res.status(400).json({ error: 'Invalid credentials' });
    }
    console.log('User found:', user);

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      console.warn('Login failed: Password does not match');
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const token = generateToken(user._id);
    console.log('JWT generated:', token);

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        username: user.username,
        email: user.email,
        dateJoined: user.dateJoined,
      },
    });
  } catch (error) {
    console.error('Error during login:', error.message);
    res.status(500).json({ error: 'Login failed' });
  }
};
