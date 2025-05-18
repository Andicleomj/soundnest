server.js

const express = require('express');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware untuk menghindari CORS
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); // Allow semua origin (Android, Web, dst)
  res.setHeader('Access-Control-Allow-Methods', 'GET');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  next();
});

// Endpoint untuk streaming file dari Google Drive
app.get('/stream/:fileId', async (req, res) => {
  const fileId = req.params.fileId;
  const url = `https://drive.google.com/uc?export=download&id=${fileId}`;

  console.log(`🔗 Mendapatkan file dengan ID: ${fileId}`);

  try {
    const response = await axios.get(url, { responseType: 'stream' });

    // Atur tipe file audio
    res.setHeader('Content-Type', 'audio/mpeg');
    response.data.pipe(res);
  } catch (error) {
    console.error('❌ Gagal mengambil audio dari Google Drive:', error.message);
    res.status(500).send('Gagal mengambil audio');
  }
});

// Jalankan server dan dengarkan dari semua IP
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server proxy berjalan di http://localhost:${PORT}`);
});
