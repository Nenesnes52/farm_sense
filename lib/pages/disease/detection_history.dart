import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetectionHistory extends StatefulWidget {
  const DetectionHistory({super.key});

  @override
  State<DetectionHistory> createState() => _DetectionHistoryState();
}

class _DetectionHistoryState extends State<DetectionHistory> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final tealColor = const Color(0xFF025464);

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Deteksi', style: GoogleFonts.poppins()),
        backgroundColor: Color.fromRGBO(7, 135, 160, 1),
        foregroundColor: Colors.white,
      ),
      body: _currentUser == null
          ? Center(
              child: Text(
                'Silakan login untuk melihat riwayat.',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('detection_history')
                  .where('userId', isEqualTo: _currentUser.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: GoogleFonts.poppins()));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada riwayat deteksi.',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  );
                }

                final historyDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: historyDocs.length,
                  itemBuilder: (context, index) {
                    final doc = historyDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Mengambil data dengan aman dan memberikan nilai default jika null
                    final String topLabel =
                        data['topLabel'] ?? 'Tidak Diketahui';
                    // final double topValue =
                    //     (data['topValue'] as num?)?.toDouble() ?? 0.0;
                    final String detectionDate =
                        data['detectionDate'] ?? 'Tanggal Tidak Ada';
                    final String detectionTime =
                        data['detectionTime'] ?? 'Waktu Tidak Ada';
                    // final Map<String, dynamic> percentagesData =
                    //     (data['percentages'] as Map<String, dynamic>?) ?? {};

                    // Format tanggal dan waktu dari timestamp jika ada, jika tidak gunakan string yang sudah ada
                    String formattedDateTime;
                    if (data['timestamp'] != null &&
                        data['timestamp'] is Timestamp) {
                      DateTime dt = (data['timestamp'] as Timestamp).toDate();
                      formattedDateTime =
                          DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
                    } else {
                      formattedDateTime = '$detectionDate, $detectionTime';
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          topLabel,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: tealColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDateTime,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        // Anda bisa menambahkan onTap untuk melihat detail lebih lanjut jika diperlukan
                        // onTap: () {
                        //   // Navigasi ke halaman detail riwayat (jika ada)
                        // },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
