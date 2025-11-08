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
  origin: ['http://localhost:3000', 'http://10.0.2.2:3000', 'http://localhost', 'http://10.0.2.2', 'http://localhost:8081'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ameya_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('MongoDB connection error:', err));

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
  
  try {
    this.password = await bcrypt.hash(this.password, 10);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password method
userSchema.methods.correctPassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
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

// Health Reports Schema
const healthReportSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  location: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    required: true,
    enum: ['wait_time', 'medication', 'service_quality', 'facility_condition', 'staff_behavior'],
  },
  severity: {
    type: String,
    required: true,
    enum: ['low', 'medium', 'high'],
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

const HealthReport = mongoose.model('HealthReport', healthReportSchema);

// PCOD Tracker Schema
const pcodTrackerSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
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
  try {
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
  } catch (error) {
    next(error);
  }
});

const PCODTracker = mongoose.model('PCODTracker', pcodTrackerSchema);

// Generate JWT Token
const signToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'your-fallback-secret-key', {
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

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-fallback-secret-key');
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

// Health check
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Server is running!',
    timestamp: new Date().toISOString(),
  });
});

// Register User
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    // --- DEBUG LOGS START ---
    console.log('DEBUG 1: Received registration request for email:', email);

    // Check if user already exists
    console.log('DEBUG 2: Checking for existing user...');
    const existingUser = await User.findOne({ email });
    
    if (existingUser) {
      console.log('DEBUG 3: User already exists. Sending 400.');
      return res.status(400).json({
        status: 'fail',
        message: 'User already exists with this email',
      });
    }

    // Create new user (This triggers pre('save') middleware for hashing)
    console.log('DEBUG 4: Creating new user (and hashing password)...');
    const newUser = await User.create({
      name: name || email.split('@')[0],
      email,
      password,
    });

    // Generate token
    const token = signToken(newUser._id);
    console.log('DEBUG 5: User created and token signed. Sending 201 response.');
    // --- DEBUG LOGS END ---

    res.status(201).json({
      status: 'success',
      token,
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
      },
    });
    
    console.log('DEBUG 6: Registration response sent successfully.'); // Final confirmation

  } catch (error) {
    console.error('Registration error:', error);
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
    
    if (!user) {
      return res.status(401).json({
        status: 'fail',
        message: 'Incorrect email or password',
      });
    }

    const isPasswordCorrect = await user.correctPassword(password);
    if (!isPasswordCorrect) {
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
    console.error('Login error:', error);
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
    console.error('Get current user error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Health Metrics Routes

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
    console.error('Get health metrics error:', error);
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
    console.error('Update health metrics error:', error);
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
    console.error('Update specific metric error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Health Reports Routes

// Get all health reports for user
app.get('/api/health/reports', protect, async (req, res) => {
  try {
    const reports = await HealthReport.find({ userId: req.user._id })
      .sort({ timestamp: -1 })
      .limit(50);

    res.status(200).json({
      status: 'success',
      reports,
    });
  } catch (error) {
    console.error('Get health reports error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Create new health report
app.post('/api/health/reports', protect, async (req, res) => {
  try {
    const { title, description, location, type, severity } = req.body;

    console.log('Creating health report with data:', req.body);

    // Validate required fields
    if (!title || !description || !location || !type || !severity) {
      return res.status(400).json({
        status: 'fail',
        message: 'All fields (title, description, location, type, severity) are required',
      });
    }

    // Validate enum values
    const validTypes = ['wait_time', 'medication', 'service_quality', 'facility_condition', 'staff_behavior'];
    const validSeverities = ['low', 'medium', 'high'];

    if (!validTypes.includes(type)) {
      return res.status(400).json({
        status: 'fail',
        message: `Invalid type. Must be one of: ${validTypes.join(', ')}`,
      });
    }

    if (!validSeverities.includes(severity)) {
      return res.status(400).json({
        status: 'fail',
        message: `Invalid severity. Must be one of: ${validSeverities.join(', ')}`,
      });
    }

    const report = await HealthReport.create({
      userId: req.user._id,
      title: title.trim(),
      description: description.trim(),
      location: location.trim(),
      type,
      severity,
    });

    console.log('Health report created successfully:', report._id);

    res.status(201).json({
      status: 'success',
      report,
    });
  } catch (error) {
    console.error('Create health report error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Get health reports statistics
app.get('/api/health/reports/statistics', protect, async (req, res) => {
  try {
    const totalReports = await HealthReport.countDocuments({ userId: req.user._id });
    const highSeverityReports = await HealthReport.countDocuments({ 
      userId: req.user._id, 
      severity: 'high' 
    });
    const mediumSeverityReports = await HealthReport.countDocuments({ 
      userId: req.user._id, 
      severity: 'medium' 
    });
    const lowSeverityReports = await HealthReport.countDocuments({ 
      userId: req.user._id, 
      severity: 'low' 
    });

    // Get reports by type
    const reportsByType = await HealthReport.aggregate([
      { $match: { userId: req.user._id } },
      { $group: { _id: '$type', count: { $sum: 1 } } }
    ]);

    res.status(200).json({
      status: 'success',
      statistics: {
        totalReports,
        highSeverityReports,
        mediumSeverityReports,
        lowSeverityReports,
        reportsByType,
      },
    });
  } catch (error) {
    console.error('Get health reports statistics error:', error);
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
    console.error('Get PCOD tracker error:', error);
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

    console.log('Updating PCOD tracker with data:', req.body);

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
    console.error('Update PCOD tracker error:', error);
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
    console.error('Patch PCOD tracker error:', error);
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
    console.error('Get PCOD statistics error:', error);
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

// Error handling middleware
//Add this after your existing schemas in server.js

// Story Schema
const storySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100,
  },
  content: {
    type: String,
    required: true,
    trim: true,
    maxlength: 2000,
  },
  category: {
    type: String,
    required: true,
    enum: [
      'Fitness Transformation',
      'Mental Health',
      'Wellness Journey', 
      'Nutrition Transformation',
      'Fitness Mindset',
      'Recovery Story',
      'Medical Journey',
      'Lifestyle Change',
      'Other'
    ],
  },
  tags: [{
    type: String,
    trim: true,
  }],
  isAnonymous: {
    type: Boolean,
    default: true,
  },
  likes: {
    type: Number,
    default: 0,
  },
  likedBy: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  readTime: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Calculate read time before saving
storySchema.pre('save', function(next) {
  const wordsPerMinute = 200;
  const wordCount = this.content.split(/\s+/).length;
  this.readTime = Math.ceil(wordCount / wordsPerMinute);
  this.updatedAt = new Date();
  next();
});

const Story = mongoose.model('Story', storySchema);

// Story Routes
app.get('/api/stories/debug', protect, async (req, res) => {
  try {
    // Check if we can create a test story
    const testStory = await Story.findOne({ title: 'Welcome to Story Hub!' });
    
    if (!testStory) {
      // Create a test story if none exists
      await Story.create({
        userId: req.user._id, // This requires a logged-in user
        title: 'Welcome to Story Hub!',
        content: 'This is a test story to make sure everything is working properly. Share your own health and wellness journey to inspire others!',
        category: 'Wellness Journey',
        tags: ['welcome', 'test'],
        isAnonymous: true,
      });
    }
    
    const stories = await Story.find().populate('userId', 'name');
    
    res.status(200).json({
      status: 'success',
      debug: {
        totalStories: await Story.countDocuments(),
        userStories: await Story.countDocuments({ userId: req.user._id }),
        allStories: stories.map(s => ({
          id: s._id,
          title: s.title,
          author: s.isAnonymous ? 'Anonymous' : s.userId.name,
          content: s.content,
          category: s.category
        }))
      }
    });
  } catch (error) {
    console.error('Debug error:', error);
    // If you are getting the "userId: Path 'userId' is required" error here, 
    // it means the 'protect' middleware failed to attach req.user, 
    // or you are trying to access this route without a valid token.
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});
// Get all stories (with pagination and filtering)
// Get all stories (with pagination and filtering)
app.get('/api/stories', protect, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const category = req.query.category;
    const sortBy = req.query.sortBy || 'createdAt';
    const sortOrder = req.query.sortOrder === 'asc' ? 1 : -1;

    const filter = {};
    if (category && category !== 'all') {
      filter.category = category;
    }

    const stories = await Story.find(filter)
      .populate('userId', 'name')
      .sort({ [sortBy]: sortOrder })
      .limit(limit)
      .skip((page - 1) * limit);

    const totalStories = await Story.countDocuments(filter);

    // Safe mapping with proper error handling
    const safeStories = stories.map(story => {
      // Ensure likedBy is always an array
      const likedBy = story.likedBy || [];
      const hasLiked = Array.isArray(likedBy) ? likedBy.includes(req.user._id.toString()) : false;
      
      return {
        id: story._id,
        title: story.title || 'Untitled',
        content: story.content || '',
        category: story.category || 'Other',
        tags: story.tags || [],
        isAnonymous: story.isAnonymous !== undefined ? story.isAnonymous : true,
        author: story.isAnonymous ? 'Anonymous' : (story.userId?.name || 'Unknown'),
        likes: story.likes || 0,
        readTime: story.readTime || 0,
        createdAt: story.createdAt,
        hasLiked: hasLiked,
      };
    });

    res.status(200).json({
      status: 'success',
      stories: safeStories,
      totalPages: Math.ceil(totalStories / limit),
      currentPage: page,
      totalStories,
    });
  } catch (error) {
    console.error('Get stories error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});
// Fix existing stories (run this once, then you can remove it)
app.get('/api/stories/fix-data', protect, async (req, res) => {
  try {
    const stories = await Story.find({ 
      $or: [
        { likedBy: { $exists: false } },
        { likedBy: null }
      ]
    });
    
    let fixedCount = 0;
    
    for (const story of stories) {
      if (!story.likedBy) {
        story.likedBy = [];
        await story.save();
        fixedCount++;
      }
    }
    
    res.status(200).json({
      status: 'success',
      message: `Fixed ${fixedCount} stories with missing likedBy field`,
      totalChecked: stories.length
    });
  } catch (error) {
    console.error('Fix stories error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});
// Get user's own stories
app.get('/api/stories/my-stories', protect, async (req, res) => {
  try {
    const stories = await Story.find({ userId: req.user._id })
      .sort({ createdAt: -1 });

    res.status(200).json({
      status: 'success',
      stories,
    });
  } catch (error) {
    console.error('Get my stories error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Create new story
app.post('/api/stories', protect, async (req, res) => {
  try {
    const { title, content, category, tags, isAnonymous } = req.body;

    // Validate required fields
    if (!title || !content || !category) {
      return res.status(400).json({
        status: 'fail',
        message: 'Title, content, and category are required',
      });
    }

    // Validate title length
    if (title.length > 100) {
      return res.status(400).json({
        status: 'fail',
        message: 'Title must be less than 100 characters',
      });
    }

    // Validate content length
    if (content.length > 2000) {
      return res.status(400).json({
        status: 'fail',
        message: 'Content must be less than 2000 characters',
      });
    }

    const story = await Story.create({
      userId: req.user._id,
      title: title.trim(),
      content: content.trim(),
      category,
      tags: tags || [],
      isAnonymous: isAnonymous !== undefined ? isAnonymous : true,
    });

    res.status(201).json({
      status: 'success',
      story: {
        id: story._id,
        title: story.title,
        content: story.content,
        category: story.category,
        tags: story.tags,
        isAnonymous: story.isAnonymous,
        author: story.isAnonymous ? 'Anonymous' : req.user.name,
        likes: story.likes,
        readTime: story.readTime,
        createdAt: story.createdAt,
        hasLiked: false,
      },
    });
  } catch (error) {
    console.error('Create story error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Like/Unlike a story
app.post('/api/stories/:id/like', protect, async (req, res) => {
  try {
    const story = await Story.findById(req.params.id);
    
    if (!story) {
      return res.status(404).json({
        status: 'fail',
        message: 'Story not found',
      });
    }

    const hasLiked = story.likedBy.includes(req.user._id);

    if (hasLiked) {
      // Unlike the story
      story.likes = Math.max(0, story.likes - 1);
      story.likedBy.pull(req.user._id);
    } else {
      // Like the story
      story.likes += 1;
      story.likedBy.push(req.user._id);
    }

    await story.save();

    res.status(200).json({
      status: 'success',
      likes: story.likes,
      hasLiked: !hasLiked,
    });
  } catch (error) {
    console.error('Like story error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Get story categories
app.get('/api/stories/categories', protect, async (req, res) => {
  try {
    const categories = await Story.distinct('category');
    
    res.status(200).json({
      status: 'success',
      categories,
    });
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

// Delete user's own story
app.delete('/api/stories/:id', protect, async (req, res) => {
  try {
    const story = await Story.findOne({ 
      _id: req.params.id, 
      userId: req.user._id 
    });
    
    if (!story) {
      return res.status(404).json({
        status: 'fail',
        message: 'Story not found or you are not authorized to delete it',
      });
    }

    await Story.findByIdAndDelete(req.params.id);

    res.status(200).json({
      status: 'success',
      message: 'Story deleted successfully',
    });
  } catch (error) {
    console.error('Delete story error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});
// Add this route before your existing story routes for debugging
app.get('/api/stories/debug', protect, async (req, res) => {
  try {
    // Check if we can create a test story
    const testStory = await Story.findOne({ title: 'Welcome to Story Hub!' });
    
    if (!testStory) {
      // Create a test story if none exists
      await Story.create({
        userId: req.user._id,
        title: 'Welcome to Story Hub!',
        content: 'This is a test story to make sure everything is working properly. Share your own health and wellness journey to inspire others!',
        category: 'Wellness Journey',
        tags: ['welcome', 'test'],
        isAnonymous: true,
      });
    }
    
    const stories = await Story.find().populate('userId', 'name');
    
    res.status(200).json({
      status: 'success',
      debug: {
        totalStories: await Story.countDocuments(),
        userStories: await Story.countDocuments({ userId: req.user._id }),
        allStories: stories.map(s => ({
          id: s._id,
          title: s.title,
          author: s.isAnonymous ? 'Anonymous' : s.userId.name,
          content: s.content,
          category: s.category
        }))
      }
    });
  } catch (error) {
    console.error('Debug error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});
// ===== ERROR HANDLING MIDDLEWARE =====
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
});

// ===== 404 HANDLER =====
// 404 handler - MUST BE LAST!
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'fail',
    message: `Route ${req.originalUrl} not found`
  });
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
});