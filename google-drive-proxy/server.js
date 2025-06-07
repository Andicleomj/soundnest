const express = require("express");
const axios = require("axios");
const fs = require("fs");
const path = require("path");

const app = express();
const API_KEY = "AIzaSyCvg8k9odUAk87UwtpCwQouOcUvWLXb1to"; 

app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Range, Content-Type, Accept, Authorization"
  );
  next();
});

function parseRange(range, totalLength) {
  const array = range.replace(/bytes=/, "").split("-");
  let start = parseInt(array[0], 10);
  let end = array[1] ? parseInt(array[1], 10) : totalLength - 1;
  if (isNaN(start) || start < 0) start = 0;
  if (isNaN(end) || end >= totalLength) end = totalLength - 1;
  if (start > end) start = 0;
  return { start, end };
}

app.get("/stream/:fileId", async (req, res) => {
  const fileId = req.params.fileId;
  if (!fileId) return res.status(400).send("fileId tidak boleh kosong");

  try {
    const tempFolder = path.resolve(__dirname, "temp");
    if (!fs.existsSync(tempFolder)) fs.mkdirSync(tempFolder);

    const filePath = path.join(tempFolder, `${fileId}.mp3`);

    if (!fs.existsSync(filePath)) {
      const downloadUrl = `https://www.googleapis.com/drive/v3/files/${fileId}?alt=media&key=${API_KEY}`;
      console.log("Downloading from Google Drive API...");

      const response = await axios.get(downloadUrl, {
        responseType: "stream",
        headers: { "User-Agent": "Mozilla/5.0" },
      });

      const writer = fs.createWriteStream(filePath);
      response.data.pipe(writer);

      await new Promise((resolve, reject) => {
        writer.on("finish", resolve);
        writer.on("error", reject);
      });

      console.log("Download selesai.");
    }

    const stat = fs.statSync(filePath);
    const fileSize = stat.size;
    const range = req.headers.range;

    if (range) {
      const { start, end } = parseRange(range, fileSize);
      const chunkSize = end - start + 1;
      const fileStream = fs.createReadStream(filePath, { start, end });

      res.writeHead(206, {
        "Content-Range": `bytes ${start}-${end}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunkSize,
        "Content-Type": "audio/mpeg",
        "Content-Disposition": `inline; filename="${fileId}.mp3"`,
      });
      fileStream.pipe(res);
    } else {
      res.writeHead(200, {
        "Content-Length": fileSize,
        "Content-Type": "audio/mpeg",
        "Content-Disposition": `inline; filename="${fileId}.mp3"`,
      });
      fs.createReadStream(filePath).pipe(res);
    }
  } catch (error) {
    console.error("Gagal streaming audio:", error.message);
    res.status(500).send("Gagal streaming audio");
  }
});

const PORT = 3000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server aktif di http:/172.20.10.7:${PORT}`);
});
