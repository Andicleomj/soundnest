const express = require('express');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware untuk menghindari CORS
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  next();
});

// Endpoint untuk streaming audio dari Google Drive
app.get('/stream/:fileId', async (req, res) => {
  const fileId = req.params.fileId;
  const url = `https://drive.google.com/uc?export=download&id=${fileId}`;

  console.log(`🔗 Mendapatkan file dengan ID: ${fileId}`);

  try {
    const response = await axios.get(url, { responseType: 'stream' });

    res.setHeader('Content-Type', 'audio/mpeg');
    response.data.pipe(res);

  } catch (error) {
    console.error('❌ Error fetching audio from Google Drive:', error.message);
    res.status(500).send('Error fetching audio');
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Proxy server berjalan di http://localhost:${PORT}`);
});
