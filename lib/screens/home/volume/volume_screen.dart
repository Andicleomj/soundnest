import 'package:flutter/material.dart';

class VolumeScreen extends StatefulWidget {
  const VolumeScreen({super.key});

  @override
  _VolumeScreenState createState() => _VolumeScreenState();
}

class _VolumeScreenState extends State<VolumeScreen> {
  double _volume = 50; // Nilai awal volume

  void _increaseVolume() {
    setState(() {
      if (_volume < 100) _volume += 10; // Maksimal 100
    });
  }

  void _decreaseVolume() {
    setState(() {
      if (_volume > 0) _volume -= 10; // Minimal 0
    });
  }

  void _saveVolume() {
    // TODO: Tambahkan logika penyimpanan volume
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Volume disimpan: $_volume")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Volume",
        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset(
            'assets/Logo 1.png', 
            width: 200,
            height: 200,
          ),

          const SizedBox(height: 150),

          // Kontrol volume
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol kurang
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.black),
                  onPressed: _decreaseVolume,
                ),

                // Label volume
                const Text(
                  "Volume",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                // Tombol tambah
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: _increaseVolume,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Tombol simpan
          ElevatedButton(
            onPressed: _saveVolume,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[200],
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Simpan",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
