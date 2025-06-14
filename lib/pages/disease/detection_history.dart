import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:farm_sense/pages/disease/detection_history_detail.dart'; // Import DetectionHistoryDetail

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
        toolbarHeight: 65,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SvgPicture.asset(
            'assets/images/back-icon.svg',
            fit: BoxFit.none,
          ),
        ),
        title: Text(
          'Riwayat Deteksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(23, 132, 204, 1),
                Color.fromRGBO(11, 66, 102, 1)
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: _currentUser == null
          ? Center(
              child: Text(
                'Silakan login untuk melihat riwayat.',
                style: GoogleFonts.plusJakartaSans(fontSize: 16),
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
                          style: GoogleFonts.plusJakartaSans()));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada riwayat deteksi.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16),
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
                        vertical: 5.0,
                        horizontal: 4.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        // contentPadding:
                        //     const EdgeInsets.symmetric(horizontal: 16.0),
                        subtitle: Text(
                          'Terdeteksi $topLabel',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: tealColor,
                          ),
                        ),
                        dense: true,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDateTime,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Color.fromRGBO(108, 145, 153, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetectionHistoryDetail(detectionData: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
