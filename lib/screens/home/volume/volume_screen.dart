import 'package:flutter/material.dart';
import 'package:soundnest/utils/audio_filter_helper.dart';
import 'package:soundnest/utils/volume_helper.dart';

class VolumeScreen extends StatefulWidget {
  const VolumeScreen({super.key});

  @override
  State<VolumeScreen> createState() => _VolumeScreenState();
}

class _VolumeScreenState extends State<VolumeScreen> {
  double _tempVolume = 50;

  @override
  void initState() {
    super.initState();
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    int savedVolume = await VolumeHelper.getVolumePercentage();
    setState(() => _tempVolume = savedVolume.toDouble());
    _applyFilter(); // Terapkan filter saat volume diload
  }

  void _increaseVolume() {
    setState(() {
      _tempVolume = (_tempVolume + 10).clamp(0, 100);
    });
    _applyFilter(); // Terapkan filter setiap naik volume
  }

  void _decreaseVolume() {
    setState(() {
      _tempVolume = (_tempVolume - 10).clamp(0, 100);
    });
    _applyFilter(); // Terapkan filter setiap turun volume
  }

  Future<void> _saveVolume() async {
    await VolumeHelper.setVolume(_tempVolume / 100);
    await _applyFilter(); // Terapkan filter saat volume disimpan

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Volume disimpan: ${_tempVolume.toInt()}%"),
        backgroundColor: Colors.blue,
        duration: const Duration(milliseconds: 1500),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _applyFilter() async {
    // Aktifkan filter jika volume bukan 0 (tetap aktif pada volume rendah)
    final enableFilter = _tempVolume > 0;
    await AudioFilterHelper.applyFilterForKids(enableFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Atur Volume",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.lightBlue.shade100,
                              Colors.blueAccent,
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: _tempVolume / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.lightBlue.shade50,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${_tempVolume.toInt()}%",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            "Volume",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleButton(
                    Icons.remove,
                    _decreaseVolume,
                    Colors.cyan,
                  ),
                  const SizedBox(width: 40),
                  _buildCircleButton(Icons.add, _increaseVolume, Colors.cyan),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveVolume,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Simpan Volume",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  bool aktif = await AudioFilterHelper.isFilterActive();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Filter Frekuensi: ${aktif ? "AKTIF" : "TIDAK AKTIF"}",
                      ),
                      backgroundColor: aktif ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Cek Filter Frekuensi",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }
}
