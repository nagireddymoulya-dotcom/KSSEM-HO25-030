const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
// Add more permissive CORS for development
app.use(cors({
  origin: ['http://localhost:3000', 'http://10.0.2.2:3000', 'http://localhost', 'http://10.0.2.2'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ameya_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', () => {
  console.log('Connected to MongoDB');
});

// User Schema
const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Compare password method
userSchema.methods.correctPassword = async function (candidatePassword, userPassword) {
  return await bcrypt.compare(candidatePassword, userPassword);
};

const User = mongoose.model('User', userSchema);

// Health Metrics Schema
const healthMetricSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  steps: {
    type: Number,
    default: 0,
  },
  temperature: {
    type: Number,
    default: 0,
  },
  heartRate: {
    type: Number,
    default: 0,
  },
  oxygenLevel: {
    type: Number,
    default: 0,
  },
  lastUpdated: {
    type: Date,
    default: Date.now,
  },
});

const HealthMetric = mongoose.model('HealthMetric', healthMetricSchema);

// PCOD Tracker Schema
const pcodTrackerSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true // Each user has one tracker
  },
  lastPeriod: {
    type: Date,
    required: true,
    default: Date.now
  },
  cycleLength: {
    type: Number,
    required: true,
    min: 21,
    max: 35,
    default: 28
  },
  periodLength: {
    type: Number,
    required: true,
    min: 3,
    max: 7,
    default: 5
  },
  symptoms: [{
    type: String
  }],
  mood: {
    type: String,
    enum: ['Happy', 'Normal', 'Sad', 'Anxious', 'Irritable', 'Energetic', 'Tired'],
    default: 'Normal'
  },
  flowIntensity: {
    type: String,
    enum: ['Light', 'Medium', 'Heavy', 'Very Heavy'],
    default: 'Medium'
  },
  medications: [{
    type: String
  }],
  notes: {
    type: String,
    default: ''
  },
  nextPredictedPeriod: {
    type: Date,
    required: true
  },
  currentCycleDay: {
    type: Number,
    required: true,
    min: 1,
    max: 35
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
});

// Pre-save middleware to calculate next period and current cycle day
pcodTrackerSchema.pre('save', function(next) {
  // Calculate next predicted period
  this.nextPredictedPeriod = new Date(this.lastPeriod);
  this.nextPredictedPeriod.setDate(this.nextPredictedPeriod.getDate() + this.cycleLength);
  
  // Calculate current cycle day
  const today = new Date();
  const timeDiff = today.getTime() - this.lastPeriod.getTime();
  this.currentCycleDay = Math.floor(timeDiff / (1000 * 3600 * 24)) + 1;
  
  // Ensure cycle day is within bounds
  if (this.currentCycleDay > this.cycleLength) {
    this.currentCycleDay = this.currentCycleDay % this.cycleLength || this.cycleLength;
  }
  
  this.lastUpdated = new Date();
  next();
});

const PCODTracker = mongoose.model('PCODTracker', pcodTrackerSchema);

// Generate JWT Token
const signToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });
};

// Auth Middleware
const protect = async (req, res, next) => {
  try {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        status: 'fail',
        message: 'You are not logged in! Please log in to get access.',
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const currentUser = await User.findById(decoded.id);
    
    if (!currentUser) {
      return res.status(401).json({
        status: 'fail',
        message: 'The user belonging to this token no longer exists.',
      });
    }

    req.user = currentUser;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'fail',
      message: 'Invalid token!',
    });
  }
};

// Routes

// Register User
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        status: 'fail',
        message: 'User already exists with this email',
      });
    }

    // Create new user
    const newUser = await User.create({
      name: name || email.split('@')[0],
      email,
      password,
    });

    // Generate token
    const token = signToken(newUser._id);

    res.status(201).json({
      status: 'success',
      token,
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
      },
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Login User
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if email and password exist
    if (!email || !password) {
      return res.status(400).json({
        status: 'fail',
        message: 'Please provide email and password',
      });
    }

    // Check if user exists and password is correct
    const user = await User.findOne({ email }).select('+password');
    
    if (!user || !(await user.correctPassword(password, user.password))) {
      return res.status(401).json({
        status: 'fail',
        message: 'Incorrect email or password',
      });
    }

    // Generate token
    const token = signToken(user._id);

    res.status(200).json({
      status: 'success',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
      },
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Get Current User (Protected route)
app.get('/api/auth/me', protect, async (req, res) => {
  try {
    res.status(200).json({
      status: 'success',
      user: {
        id: req.user._id,
        name: req.user.name,
        email: req.user.email,
      },
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Server is running!',
    timestamp: new Date().toISOString(),
  });
});

// Get user health metrics
app.get('/api/health/metrics', protect, async (req, res) => {
  try {
    let metrics = await HealthMetric.findOne({ userId: req.user._id });
    
    if (!metrics) {
      // Create default metrics if none exist
      metrics = await HealthMetric.create({
        userId: req.user._id,
        steps: 0,
        temperature: 0,
        heartRate: 0,
        oxygenLevel: 0,
      });
    }
    
    res.status(200).json({
      status: 'success',
      metrics,
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Update health metrics
app.patch('/api/health/metrics', protect, async (req, res) => {
  try {
    const { steps, temperature, heartRate, oxygenLevel } = req.body;
    
    let metrics = await HealthMetric.findOne({ userId: req.user._id });
    
    if (!metrics) {
      metrics = await HealthMetric.create({
        userId: req.user._id,
        steps: steps || 0,
        temperature: temperature || 0,
        heartRate: heartRate || 0,
        oxygenLevel: oxygenLevel || 0,
      });
    } else {
      // Update only provided fields
      if (steps !== undefined) metrics.steps = steps;
      if (temperature !== undefined) metrics.temperature = temperature;
      if (heartRate !== undefined) metrics.heartRate = heartRate;
      if (oxygenLevel !== undefined) metrics.oxygenLevel = oxygenLevel;
      
      metrics.lastUpdated = new Date();
      await metrics.save();
    }
    
    res.status(200).json({
      status: 'success',
      metrics,
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Update specific metric
app.patch('/api/health/metrics/:metric', protect, async (req, res) => {
  try {
    const { metric } = req.params;
    const { value } = req.body;
    
    const allowedMetrics = ['steps', 'temperature', 'heartRate', 'oxygenLevel'];
    
    if (!allowedMetrics.includes(metric)) {
      return res.status(400).json({
        status: 'fail',
        message: 'Invalid metric type',
      });
    }
    
    let healthMetrics = await HealthMetric.findOne({ userId: req.user._id });
    
    if (!healthMetrics) {
      healthMetrics = await HealthMetric.create({
        userId: req.user._id,
        [metric]: value,
      });
    } else {
      healthMetrics[metric] = value;
      healthMetrics.lastUpdated = new Date();
      await healthMetrics.save();
    }
    
    res.status(200).json({
      status: 'success',
      metrics: healthMetrics,
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// PCOD Tracker Routes

// Get PCOD tracker data
app.get('/api/pcod/tracker', protect, async (req, res) => {
  try {
    let tracker = await PCODTracker.findOne({ userId: req.user._id });
    
    if (!tracker) {
      // Create default tracker if none exists
      const defaultLastPeriod = new Date();
      defaultLastPeriod.setDate(defaultLastPeriod.getDate() - 15); // 15 days ago
      
      tracker = await PCODTracker.create({
        userId: req.user._id,
        lastPeriod: defaultLastPeriod,
        cycleLength: 28,
        periodLength: 5,
        symptoms: ['Cramps', 'Headache'],
        mood: 'Normal',
        flowIntensity: 'Medium',
        medications: ['Pain reliever'],
        notes: 'Feeling okay today'
      });
    }
    
    res.status(200).json({
      status: 'success',
      tracker: {
        lastPeriod: tracker.lastPeriod,
        cycleLength: tracker.cycleLength,
        periodLength: tracker.periodLength,
        symptoms: tracker.symptoms,
        mood: tracker.mood,
        flowIntensity: tracker.flowIntensity,
        medications: tracker.medications,
        notes: tracker.notes,
        nextPredictedPeriod: tracker.nextPredictedPeriod,
        currentCycleDay: tracker.currentCycleDay,
        lastUpdated: tracker.lastUpdated
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// Create or Update PCOD tracker
app.post('/api/pcod/tracker', protect, async (req, res) => {
  try {
    const {
      lastPeriod,
      cycleLength,
      periodLength,
      symptoms,
      mood,
      flowIntensity,
      medications,
      notes
    } = req.body;

    // Validate required fields
    if (!lastPeriod) {
      return res.status(400).json({
        status: 'fail',
        message: 'Last period date is required'
      });
    }

    let tracker = await PCODTracker.findOne({ userId: req.user._id });

    if (tracker) {
      // Update existing tracker
      tracker.lastPeriod = new Date(lastPeriod);
      tracker.cycleLength = cycleLength || tracker.cycleLength;
      tracker.periodLength = periodLength || tracker.periodLength;
      tracker.symptoms = symptoms || tracker.symptoms;
      tracker.mood = mood || tracker.mood;
      tracker.flowIntensity = flowIntensity || tracker.flowIntensity;
      tracker.medications = medications || tracker.medications;
      tracker.notes = notes || tracker.notes;
      
      await tracker.save();
    } else {
      // Create new tracker
      tracker = await PCODTracker.create({
        userId: req.user._id,
        lastPeriod: new Date(lastPeriod),
        cycleLength: cycleLength || 28,
        periodLength: periodLength || 5,
        symptoms: symptoms || [],
        mood: mood || 'Normal',
        flowIntensity: flowIntensity || 'Medium',
        medications: medications || [],
        notes: notes || ''
      });
    }

    res.status(200).json({
      status: 'success',
      tracker: {
        lastPeriod: tracker.lastPeriod,
        cycleLength: tracker.cycleLength,
        periodLength: tracker.periodLength,
        symptoms: tracker.symptoms,
        mood: tracker.mood,
        flowIntensity: tracker.flowIntensity,
        medications: tracker.medications,
        notes: tracker.notes,
        nextPredictedPeriod: tracker.nextPredictedPeriod,
        currentCycleDay: tracker.currentCycleDay,
        lastUpdated: tracker.lastUpdated
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// Update specific PCOD fields
app.patch('/api/pcod/tracker', protect, async (req, res) => {
  try {
    const updates = req.body;
    const allowedUpdates = [
      'symptoms', 'mood', 'flowIntensity', 'medications', 'notes',
      'cycleLength', 'periodLength', 'lastPeriod'
    ];
    
    const isValidOperation = Object.keys(updates).every(update => 
      allowedUpdates.includes(update)
    );
    
    if (!isValidOperation) {
      return res.status(400).json({
        status: 'fail',
        message: 'Invalid updates!'
      });
    }
    
    let tracker = await PCODTracker.findOne({ userId: req.user._id });
    
    if (!tracker) {
      return res.status(404).json({
        status: 'fail',
        message: 'PCOD tracker not found'
      });
    }
    
    // Apply updates
    Object.keys(updates).forEach(update => {
      tracker[update] = updates[update];
    });
    
    await tracker.save();
    
    res.status(200).json({
      status: 'success',
      tracker: {
        lastPeriod: tracker.lastPeriod,
        cycleLength: tracker.cycleLength,
        periodLength: tracker.periodLength,
        symptoms: tracker.symptoms,
        mood: tracker.mood,
        flowIntensity: tracker.flowIntensity,
        medications: tracker.medications,
        notes: tracker.notes,
        nextPredictedPeriod: tracker.nextPredictedPeriod,
        currentCycleDay: tracker.currentCycleDay,
        lastUpdated: tracker.lastUpdated
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// Get PCOD statistics
app.get('/api/pcod/statistics', protect, async (req, res) => {
  try {
    const tracker = await PCODTracker.findOne({ userId: req.user._id });
    
    if (!tracker) {
      return res.status(404).json({
        status: 'fail',
        message: 'PCOD tracker not found'
      });
    }
    
    // Calculate basic statistics
    const statistics = {
      averageCycleLength: tracker.cycleLength,
      averagePeriodLength: tracker.periodLength,
      currentPhase: getCurrentPhase(tracker.currentCycleDay),
      daysUntilNextPeriod: Math.ceil((tracker.nextPredictedPeriod - new Date()) / (1000 * 3600 * 24)),
      commonSymptoms: getCommonSymptoms(tracker.symptoms),
      moodAnalysis: analyzeMood(tracker.mood)
    };
    
    res.status(200).json({
      status: 'success',
      statistics
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// Helper functions
function getCurrentPhase(cycleDay) {
  if (cycleDay <= 7) return 'Menstrual';
  if (cycleDay <= 14) return 'Follicular';
  if (cycleDay <= 21) return 'Ovulation';
  return 'Luteal';
}

function getCommonSymptoms(symptoms) {
  if (!symptoms || symptoms.length === 0) return [];
  
  const symptomCount = {};
  symptoms.forEach(symptom => {
    symptomCount[symptom] = (symptomCount[symptom] || 0) + 1;
  });
  
  return Object.entries(symptomCount)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(entry => entry[0]);
}

function analyzeMood(mood) {
  const moodAnalysis = {
    'Happy': 'Positive',
    'Energetic': 'Positive', 
    'Normal': 'Stable',
    'Tired': 'Needs Rest',
    'Sad': 'Needs Support',
    'Anxious': 'Needs Support',
    'Irritable': 'Needs Support'
  };
  
  return moodAnalysis[mood] || 'Stable';
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});