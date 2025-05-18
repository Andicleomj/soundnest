const express = require('express');
const axios = require('axios');
const path = require('path');
const fs = require('fs');
const cors = require('cors');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Enhanced CORS configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'HEAD'],
  allowedHeaders: ['Content-Type']
}));

// Request logging
app.use(morgan('dev'));

// Serve static files from public directory
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date() });
});

// Enhanced Google Drive streaming endpoint
app.get('/stream/:fileId', async (req, res) => {
  const fileId = req.params.fileId;
  
  // Validate fileId format
  if (!fileId || fileId.length < 10) {
    return res.status(400).json({ error: 'Invalid file ID format' });
  }

  const url = `https://drive.google.com/uc?export=download&id=${fileId}`;
  console.log(`🔗 Requesting file from Google Drive with ID: ${fileId}`);

  try {
    const response = await axios({
      method: 'get',
      url: url,
      responseType: 'stream',
      timeout: 10000 // 10 seconds timeout
    });

    // Set proper audio headers
    res.set({
      'Content-Type': 'audio/mpeg',
      'Content-Disposition': 'inline',
      'Cache-Control': 'public, max-age=31536000'
    });

    // Pipe the audio stream
    response.data.pipe(res);

    // Log successful streaming
    response.data.on('end', () => {
      console.log(`✅ Successfully streamed file: ${fileId}`);
    });

  } catch (error) {
    console.error(`❌ Failed to stream file ${fileId}:`, error.message);
    
    // Differentiate between timeout and other errors
    if (error.code === 'ECONNABORTED') {
      res.status(504).json({ error: 'Google Drive timeout' });
    } else {
      res.status(502).json({ error: 'Failed to fetch from Google Drive' });
    }
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('🔥 Server error:', err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📌 Endpoints:`);
  console.log(`- GET /health - Service health check`);
  console.log(`- GET /stream/:fileId - Stream audio from Google Drive`);
});