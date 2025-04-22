import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Pastikan ini untuk inisialisasi Firebase jika belum dilakukan sebelumnya
import '../models/schedule_model.dart'; // Pastikan path import sesuai dengan struktur folder proyek kamu

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inisialisasi Firebase jika belum dilakukan
  Future<void> initialize() async {
    await Firebase.initializeApp(); // Pastikan Firebase diinisialisasi sebelum menggunakan Firestore
  }

  // Mengambil jadwal dari Firestore
  Future<List<Schedule>> getSchedules() async {
    try {
      final snapshot = await _firestore.collection('penjadwalan').get();

      // Mengecek apakah data kosong
      if (snapshot.docs.isEmpty) {
        return [];
      }

      // Mengembalikan daftar Schedule yang dipetakan dari data Firestore
      return snapshot.docs.map((doc) {
        return Schedule.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // Menangani error dan mencetak pesan error
      print("Error getting schedules: $e");
      return [];
    }
  }
}
