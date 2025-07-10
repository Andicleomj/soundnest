import 'dart:math';
import 'package:flutter/material.dart';
import 'package:soundnest/utils/volume_helper.dart';
import 'package:volume_controller/volume_controller.dart';
import 'dart:developer' as dev;

class VolumeScreen extends StatefulWidget {
  const VolumeScreen({super.key});

  @override
  State<VolumeScreen> createState() => _VolumeScreenState();
}

class _VolumeScreenState extends State<VolumeScreen> {
  double _tempVolume = 50; // Persentase volume (0-100)
  double _spl = 0.0; // Sound Pressure Level dalam dB
  double _distance = 1.0; // Jarak default dalam meter (1-3 meter)

  @override
  void initState() {
    super.initState();
    _initializeVolume();
  }

  Future<void> _initializeVolume() async {
    try {
      int savedVolume = await VolumeHelper.getVolumePercentage();
      setState(() {
        _tempVolume = savedVolume.toDouble().clamp(0, 100);
        _calculateSPL();
      });
      await _setOsVolume(_tempVolume / 100);
      dev.log(
        "🎧 Volume diinisialisasi: $_tempVolume%, SPL: ${_spl.toStringAsFixed(2)} dB",
        name: "VolumeScreen",
      );
    } catch (e) {
      dev.log("❌ Error initializing volume: $e", name: "VolumeScreen");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat volume awal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _increaseVolume() {
    setState(() {
      _tempVolume = (_tempVolume + 10).clamp(0, 100);
      _calculateSPL();
    });
    _updateVolume();
  }

  void _decreaseVolume() {
    setState(() {
      _tempVolume = (_tempVolume - 10).clamp(0, 100);
      _calculateSPL();
    });
    _updateVolume();
  }

  Future<void> _updateVolume() async {
    try {
      await _setOsVolume(_tempVolume / 100);
      dev.log(
        "🔧 Volume diperbarui: $_tempVolume%, SPL: ${_spl.toStringAsFixed(2)} dB",
        name: "VolumeScreen",
      );
    } catch (e) {
      dev.log("❌ Error updating volume: $e", name: "VolumeScreen");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui volume"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setOsVolume(double volume) async {
    try {
      VolumeController().showSystemUI = false;
      VolumeController().setVolume(volume);
      dev.log("🎵 OS volume disetel ke: $volume", name: "VolumeScreen");
    } catch (e) {
      dev.log("❌ Error setting OS volume: $e", name: "VolumeScreen");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengatur volume sistem"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveVolume() async {
    try {
      await VolumeHelper.setVolume(_tempVolume / 100);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Volume disimpan: ${_tempVolume.toInt()}%, SPL: ${_spl.toStringAsFixed(2)} dB",
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) Navigator.pop(context);
      dev.log("💾 Volume disimpan: $_tempVolume%", name: "VolumeScreen");
    } catch (e) {
      dev.log("❌ Error saving volume: $e", name: "VolumeScreen");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menyimpan volume"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateSPL() {
    try {
      const splMax1m = 90.0;
      double volumeRatio = _tempVolume / 100;
      if (volumeRatio <= 0) volumeRatio = 0.01;
      double distanceFactor = 20 * (log(_distance) / ln10);

      double spl = splMax1m + (20 * (log(volumeRatio) / ln10)) - distanceFactor;
      setState(() {
        _spl = spl.clamp(0, 90.0);
      });
      dev.log(
        "📊 SPL dihitung: ${_spl.toStringAsFixed(2)} dB (Volume: $_tempVolume%, Jarak: $_distance m)",
        name: "VolumeScreen",
      );
    } catch (e) {
      dev.log("❌ Error calculating SPL: $e", name: "VolumeScreen");
      setState(() {
        _spl = 0.0;
      });
    }
  }

  void _increaseDistance() {
    setState(() {
      _distance = (_distance + 0.5).clamp(1.0, 3.0);
      _calculateSPL();
    });
  }

  void _decreaseDistance() {
    setState(() {
      _distance = (_distance - 0.5).clamp(1.0, 3.0);
      _calculateSPL();
    });
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
                          const SizedBox(height: 8),
                          Text(
                            "SPL: ${_spl.toStringAsFixed(2)} dB",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Jarak: ${_distance.toStringAsFixed(1)} m",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleButton(
                    Icons.remove,
                    _decreaseDistance,
                    Colors.orange,
                  ),
                  const SizedBox(width: 40),
                  _buildCircleButton(
                    Icons.add,
                    _increaseDistance,
                    Colors.orange,
                  ),
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