import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:soundnest/utils/volume_helper.dart';
import 'package:volume_controller/volume_controller.dart';
import 'dart:developer' as dev;

enum Environment { indoor, outdoor }

class VolumeScreen extends StatefulWidget {
  const VolumeScreen({super.key});

  @override
  State<VolumeScreen> createState() => _VolumeScreenState();
}

class _VolumeScreenState extends State<VolumeScreen> {
  double _tempVolume = 50.0;
  double _spl = 0.0;
  double _distance = 1.0;
  Environment _environment = Environment.indoor;
  double _backgroundNoise = 70.0;

  final PageController _pageController = PageController();

  static const double kBtnSize = 56;
  static const double kIconSize = 28;
  static const double kGapSmall = 20;

  @override
  void initState() {
    super.initState();
    _initializeVolume();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeVolume() async {
    try {
      int savedVolume = await VolumeHelper.getVolumePercentage();
      setState(() {
        _tempVolume = savedVolume.toDouble().clamp(0, 100);
        _calculateSPL();
      });
      await _setOsVolume(_tempVolume / 100);
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
    // 🔁 Ganti validasi berdasarkan SPL (bukan _tempVolume)
    if (_spl <= 10.0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("SPL Terlalu Kecil"),
          content: Text(
            "Tingkat tekanan suara (SPL) saat ini sangat kecil (${_spl.toStringAsFixed(2)} dB). "
            "Apakah Anda yakin ingin menyimpannya?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Lanjutkan"),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    } else if (_spl <= 30.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠ SPL rendah (${_spl.toStringAsFixed(2)} dB). Pastikan ini yang Anda inginkan."),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 2100));
    }

    // Simpan volume jika lolos validasi
    await VolumeHelper.setVolume(_tempVolume / 100);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅ Volume disimpan: ${_tempVolume.toInt()}%, SPL: ${_spl.toStringAsFixed(2)} dB",
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) Navigator.pop(context);

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
      double splMax1m = _environment == Environment.indoor ? 85.0 : 80.0;
      double backgroundNoise = _environment == Environment.indoor ? 70.0 : 60.0;

      double volumeRatio = _tempVolume / 100;
      if (volumeRatio <= 0) volumeRatio = 0.01;
      double distanceFactor = 20 * (log(_distance) / ln10);

      double splAudio =
          splMax1m + (20 * (log(volumeRatio) / ln10)) - distanceFactor;
      double splEfektif = (splAudio - backgroundNoise).clamp(0.0, splMax1m);

      setState(() {
        _spl = splEfektif;
        _backgroundNoise = backgroundNoise;
      });
    } catch (e) {
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

  void _toggleEnvironment() {
    final newEnvironment =
        _environment == Environment.indoor
            ? Environment.outdoor
            : Environment.indoor;

    setState(() {
      _environment = newEnvironment;
    });

    _calculateSPL();
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBtnSize / 2),
      child: Container(
        width: kBtnSize,
        height: kBtnSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Icon(icon, size: kIconSize, color: Colors.white),
      ),
    );
  }

  Widget _buildVolumePage() {
    return Padding(
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
                        colors: [Colors.lightBlue.shade100, Colors.blueAccent],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: _tempVolume / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.blueAccent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_tempVolume.toInt()}%",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "SPL Efektif: ${_spl.toStringAsFixed(2)} dB",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Jarak: ${_distance.toStringAsFixed(1)} m",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Lingkungan: ${_environment.name.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Kebisingan: ${_backgroundNoise.toStringAsFixed(1)} dB",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleButton(Icons.remove, _decreaseVolume, Colors.cyan),
              const SizedBox(width: 50),
              _buildCircleButton(Icons.add, _increaseVolume, Colors.cyan),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Volume",
            style: TextStyle(
              fontSize: 16,
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleButton(
                Icons.remove,
                _decreaseDistance,
                Colors.orange,
              ),
              const SizedBox(width: 50),
              _buildCircleButton(Icons.add, _increaseDistance, Colors.orange),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Jarak",
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _toggleEnvironment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              _environment == Environment.indoor
                  ? "Ganti ke OUTDOOR"
                  : "Ganti ke INDOOR",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _saveVolume,
            icon: const Icon(Icons.save, color: Colors.white, size: 20),
            label: const Text(
              "Simpan",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              Text(
                "Penjelasan Volume dan SPL",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Volume adalah tingkat kekuatan suara dalam persentase. SPL (Sound Pressure Level) menunjukkan kekuatan suara efektif yang didengar, dipengaruhi oleh volume, jarak, dan lingkungan.\n\n"
                "- Volume tinggi tidak selalu menghasilkan SPL tinggi jika jaraknya jauh.\n"
                "- Lingkungan indoor/outdoor memiliki kebisingan berbeda.\n"
                "- Sistem ini membantu menyetel volume agar suara tetap nyaman dan tidak mengganggu.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
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
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [_buildVolumePage(), _buildInfoPage()],
              ),
            ),
            const SizedBox(height: 10),
            SmoothPageIndicator(
              controller: _pageController,
              count: 2,
              effect: const WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                spacing: 16,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
