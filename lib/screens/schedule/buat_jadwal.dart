import 'package:flutter/material.dart';
import 'package:soundnest/screens/schedule/murotal.dart';
import 'package:soundnest/screens/schedule/musik.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  void _navigateToMusik(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MusikScheduleForm()),
    );
  }

  void _navigateToMurottal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MurottalScheduleForm()),
    );
  }

  List<Widget> _buildStars(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> positions = [
      {'top': 40.0, 'left': 30.0, 'size': 40.0, 'color': Colors.white},
      {'top': 80.0, 'left': screenWidth * 0.7, 'size': 80.0, 'color': Colors.yellowAccent},
      {'top': 120.0, 'left': screenWidth * 0.3, 'size': 12.0, 'color': Colors.blueAccent},
      {'top': screenHeight * 0.3, 'left': 50.0, 'size': 40.0, 'color': Colors.pinkAccent},
      {'top': screenHeight * 0.45, 'left': screenWidth * 0.6, 'size': 10.0, 'color': Colors.white},
      {'top': screenHeight * 0.65, 'left': screenWidth * 0.4, 'size':40.0, 'color': Colors.cyanAccent},
      {'top': screenHeight * 0.25, 'left': screenWidth * 0.5, 'size': 60.0, 'color': Colors.lightBlueAccent},
      {'top': screenHeight * 0.38, 'left': screenWidth * 0.8, 'size': 20.0, 'color': Colors.white},
      {'top': screenHeight * 0.5, 'left': screenWidth * 0.2, 'size': 60.0, 'color': Colors.white},
      {'top': screenHeight * 0.42, 'left': screenWidth * 0.6, 'size': 50.0, 'color': Colors.white},
       {'top': screenHeight * 0.1, 'left': screenWidth * 0.9, 'size': 20.0, 'color': Colors.orange},
  {'top': screenHeight * 0.6, 'left': screenWidth * 0.1, 'size': 15.0, 'color': Colors.white},
  {'top': screenHeight * 0.75, 'left': screenWidth * 0.7, 'size': 50.0, 'color': Colors.purpleAccent},
  {'top': screenHeight * 0.85, 'left': screenWidth * 0.3, 'size': 50.0, 'color': Colors.greenAccent},
    ];

    return positions.map((pos) => Positioned(
      top: pos['top'],
      left: pos['left'],
      child: _buildStar(size: pos['size'], color: pos['color']),
    )).toList();
  }

  Widget _buildStar({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildScheduleButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: 300,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 150,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFE0E0),
                Color(0xFFFFF4C2),
                Color(0xFFCCF2F4),
                Color(0xFFE0BBE4),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.fromARGB(255, 115, 166, 255),
              width: 2,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Jadwal",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFA4D6FF),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
          ),

          // Bintang-bintang
          ..._buildStars(context),

          // Konten utama
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildScheduleButton(
                    text: "Jadwal Musik",
                    onTap: () => _navigateToMusik(context),
                  ),
                  const SizedBox(height: 40),
                  _buildScheduleButton(
                    text: "Jadwal Murottal",
                    onTap: () => _navigateToMurottal(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
