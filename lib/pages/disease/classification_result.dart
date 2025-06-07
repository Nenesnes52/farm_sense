import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_sense/routes/route_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ClassificationResult extends StatefulWidget {
  final double coccidiosis;
  final double sehat;
  final double newcastle;
  final double salmonella;
  final String topLabel;
  final double topValue;
  final File? processedImageFile;

  const ClassificationResult({
    required this.coccidiosis,
    required this.sehat,
    required this.newcastle,
    required this.salmonella,
    required this.topLabel,
    required this.topValue,
    required this.processedImageFile,
    super.key,
  });

  @override
  State<ClassificationResult> createState() => _ClassificationResultState();
}

class _ClassificationResultState extends State<ClassificationResult> {
  // Helper untuk baris persentase
  // Widget _buildResultRow(String label, double value, BuildContext context) {
  //   bool isTop = label == widget.topLabel;
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 5.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: GoogleFonts.plusJakartaSans(
  //             fontSize: 14,
  //             fontWeight: isTop ? FontWeight.w600 : FontWeight.normal,
  //             color: isTop ? const Color(0xFF025464) : Colors.black87,
  //           ),
  //         ),
  //         Text(
  //           '${value.toStringAsFixed(2)}%',
  //           style: GoogleFonts.plusJakartaSans(
  //             fontSize: 14,
  //             fontWeight: isTop ? FontWeight.w600 : FontWeight.normal,
  //             color: isTop ? const Color(0xFF025464) : Colors.black87,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Helper untuk item daftar bernomor
  Widget _buildNumberedListItem(BuildContext context, int number, String text,
      {TextStyle? style, bool isWarning = false}) {
    final defaultStyle = GoogleFonts.plusJakartaSans(
        fontSize: 14, height: 1.6, color: Colors.black87);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: style ??
                defaultStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isWarning
                        ? Colors.red.shade700
                        : const Color(0xFF025464)),
          ),
          Expanded(
            child: Text(
              text,
              style: style ??
                  defaultStyle.copyWith(
                      color: isWarning ? Colors.red.shade700 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk item daftar berpoin (bullet)
  Widget _buildBulletedListItem(BuildContext context, String text,
      {TextStyle? style, int indentLevel = 0, bool isWarning = false}) {
    final defaultStyle = GoogleFonts.plusJakartaSans(
        fontSize: 14, height: 1.6, color: Colors.black87);
    final bullet = indentLevel == 0 ? "•" : (indentLevel == 1 ? "◦" : "▪");

    return Padding(
      padding: EdgeInsets.only(left: indentLevel * 16.0, bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$bullet ",
            style: style ??
                defaultStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWarning
                        ? Colors.red.shade700
                        : const Color(0xFF025464)),
          ),
          Expanded(
            child: Text(
              text,
              style: style ??
                  defaultStyle.copyWith(
                      color: isWarning ? Colors.red.shade700 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseSpecificInfo(BuildContext context, String disease) {
    List<Widget> recommendations = [];
    List<Widget> treatments = [];
    String recommendationTitle = "Rekomendasi";
    String treatmentTitle = "Pengobatan";

    TextStyle sectionHeaderStyle = GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800);
    TextStyle normalTextStyle = GoogleFonts.plusJakartaSans(
        fontSize: 14, height: 1.6, color: Colors.black87);

    switch (disease) {
      case "Salmonella":
        recommendations = [
          _buildNumberedListItem(context, 1,
              "Segera isolasi ayam yang menunjukkan gejala dari kelompoknya."),
          _buildNumberedListItem(context, 2,
              "Lakukan sanitasi dan disinfeksi kandang secara menyeluruh dengan desinfektan yang efektif terhadap bakteri Salmonella."),
          _buildNumberedListItem(context, 3,
              "Tingkatkan biosekuriti: batasi akses orang luar, kontrol hama (tikus, lalat), dan jaga kebersihan peralatan."),
          _buildNumberedListItem(context, 4,
              "Pastikan sumber air minum bersih dan tidak terkontaminasi."),
          _buildNumberedListItem(context, 5,
              "Evaluasi kualitas pakan, hindari pakan yang lembab atau terkontaminasi."),
        ];
        treatments = [
          _buildBulletedListItem(context,
              "Konsultasikan dengan dokter hewan untuk diagnosis pasti dan pemilihan antibiotik yang tepat. Hindari penggunaan antibiotik tanpa resep.",
              isWarning: true),
          _buildBulletedListItem(
              context, "Contoh antibiotik (atas anjuran dokter hewan):",
              indentLevel: 1),
          _buildBulletedListItem(context, "Amoksisilin", indentLevel: 2),
          _buildBulletedListItem(context, "Enrofloksasin", indentLevel: 2),
          _buildBulletedListItem(context, "Sulfonamida", indentLevel: 2),
          _buildBulletedListItem(context,
              "Berikan terapi suportif seperti elektrolit dan vitamin untuk membantu pemulihan."),
          _buildBulletedListItem(context,
              "Ayam yang sudah sembuh tetap bisa menjadi carrier. Pertimbangkan pengafkiran jika kasus parah dan berulang untuk memutus siklus.",
              isWarning: true),
        ];
        break;
      case "Coccidiosis":
        recommendations = [
          _buildNumberedListItem(context, 1,
              "Jaga kebersihan litter/alas kandang tetap kering dan ganti secara berkala."),
          _buildNumberedListItem(context, 2,
              "Hindari kepadatan ayam yang berlebihan dalam kandang."),
          _buildNumberedListItem(context, 3,
              "Gunakan pakan yang mengandung koksidiostat (pencegah koksidiosis) secara preventif, terutama pada masa brooding."),
          _buildNumberedListItem(context, 4,
              "Pastikan tempat pakan dan minum tidak terkontaminasi feses."),
          _buildNumberedListItem(context, 5,
              "Isolasi ayam yang sakit untuk mencegah penyebaran oosista."),
        ];
        treatments = [
          _buildBulletedListItem(context,
              "Berikan obat antikoksidia sesuai dosis anjuran dokter hewan, contoh:",
              isWarning: true),
          _buildBulletedListItem(context, "Toltrazuril", indentLevel: 1),
          _buildBulletedListItem(context, "Amprolium", indentLevel: 1),
          _buildBulletedListItem(context, "Sulfaquinoxalin", indentLevel: 1),
          _buildBulletedListItem(context,
              "Berikan vitamin A dan K untuk membantu memperbaiki kerusakan usus dan proses pembekuan darah."),
          _buildBulletedListItem(context,
              "Sanitasi kandang dengan desinfektan yang efektif membunuh oosista."),
        ];
        break;
      case "Newcastle Disease":
        recommendationTitle = "Tindakan Pencegahan & Penanganan Darurat";
        recommendations = [
          _buildNumberedListItem(context, 1,
              "Vaksinasi ND secara rutin dan terjadwal adalah kunci utama pencegahan. Pastikan program vaksinasi sesuai dengan kondisi daerah Anda.",
              isWarning: true),
          _buildNumberedListItem(context, 2,
              "Terapkan biosekuriti yang sangat ketat: disinfeksi kendaraan dan orang yang masuk area peternakan, batasi lalu lintas unggas."),
          _buildNumberedListItem(context, 3,
              "Isolasi total ayam yang terduga sakit. Segera laporkan ke dinas peternakan setempat jika ada dugaan wabah.",
              isWarning: true),
          _buildNumberedListItem(context, 4,
              "Lakukan depopulasi (pemusnahan terbatas) pada kelompok ayam yang terinfeksi parah untuk mencegah penyebaran lebih luas, sesuai arahan otoritas.",
              isWarning: true),
        ];
        treatmentTitle = "Dukungan & Pengendalian Wabah";
        treatments = [
          _buildBulletedListItem(context,
              "Tidak ada pengobatan spesifik untuk menyembuhkan Newcastle Disease. Fokus utama adalah PENCEGAHAN melalui vaksinasi.",
              isWarning: true),
          _buildBulletedListItem(context,
              "Terapi suportif dapat diberikan untuk mengurangi gejala sekunder:",
              style: normalTextStyle),
          _buildBulletedListItem(context,
              "Pemberian antibiotik untuk infeksi bakteri oportunistik.",
              indentLevel: 1),
          _buildBulletedListItem(context, "Vitamin dan pakan berkualitas.",
              indentLevel: 1),
          _buildBulletedListItem(context,
              "Desinfeksi menyeluruh area kandang dan peralatan setelah wabah."),
        ];
        break;
      case "Sehat":
        recommendationTitle = "Tips Menjaga Kesehatan Ayam Tetap Optimal";
        recommendations = [
          _buildNumberedListItem(context, 1,
              "Lanjutkan praktik manajemen kandang yang baik (kebersihan, ventilasi, suhu)."),
          _buildNumberedListItem(context, 2,
              "Berikan pakan berkualitas dan air minum bersih secara berkelanjutan."),
          _buildNumberedListItem(context, 3,
              "Pantau kesehatan ayam secara rutin, perhatikan perubahan perilaku atau fisik."),
          _buildNumberedListItem(context, 4,
              "Laksanakan program vaksinasi sesuai jadwal untuk penyakit endemik di daerah Anda."),
          _buildNumberedListItem(context, 5,
              "Jaga biosekuriti kandang untuk mencegah masuknya bibit penyakit."),
        ];
        treatmentTitle = "Tindakan Lanjutan";
        treatments = [
          _buildBulletedListItem(context,
              "Tidak diperlukan pengobatan spesifik karena ayam dalam kondisi sehat."),
          _buildBulletedListItem(context,
              "Fokus pada upaya preventif dan pemeliharaan kondisi optimal."),
        ];
        break;
      default:
        recommendations = [
          _buildBulletedListItem(context,
              "Informasi rekomendasi tidak tersedia untuk kondisi ini.")
        ];
        treatments = [
          _buildBulletedListItem(
              context, "Informasi pengobatan tidak tersedia untuk kondisi ini.")
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recommendationTitle, style: sectionHeaderStyle),
        const SizedBox(height: 10),
        ...recommendations,
        const SizedBox(height: 20),
        Text(treatmentTitle, style: sectionHeaderStyle),
        const SizedBox(height: 10),
        ...treatments,
      ],
    );
  }

  bool _isSaving = false;

  Future<void> _saveDetectionResult() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan: Pengguna tidak terautentikasi.'),
          backgroundColor: Colors.red,
        ),
      );
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            authRoute, (Route<dynamic> route) => false);
      }

      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      final now = DateTime.now();
      final String formattedDate =
          DateFormat('d MMMM yyyy', 'id_ID').format(now);
      final String formattedTime = DateFormat('HH:mm:ss', 'id_ID').format(now);

      Map<String, dynamic> dataToSave = {
        // 'userEmail': currentUser.email,
        'userId': currentUser.uid,
        'detectionDate': formattedDate,
        'detectionTime': formattedTime,
        'timestamp': FieldValue.serverTimestamp(), // Untuk pengurutan di server
        'topLabel': widget.topLabel,
        'topValue': widget.topValue,
        'percentages': {
          'Coccidiosis': widget.coccidiosis,
          'Sehat': widget.sehat,
          'Newcastle Disease': widget.newcastle,
          'Salmonella': widget.salmonella,
        },
        // Anda bisa menambahkan URL gambar jika menyimpannya ke Firebase Storage
        // 'imageUrl': 'URL_GAMBAR_JIKA_ADA'
      };

      await FirebaseFirestore.instance
          .collection('detection_history')
          .add(dataToSave);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hasil deteksi berhasil disimpan.'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal menyimpan hasil: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> results = [
      {'label': 'Coccidiosis', 'value': widget.coccidiosis},
      {'label': 'Sehat', 'value': widget.sehat},
      {'label': 'Newcastle Disease', 'value': widget.newcastle},
      {'label': 'Salmonella', 'value': widget.salmonella},
    ];
    results
        .sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    final tealColor = Color.fromRGBO(91, 158, 172, 1);
    final dateNow = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
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
          'Hasil deteksi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.processedImageFile != null)
                    Center(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          widget.processedImageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hasil Deteksi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Color.fromRGBO(108, 145, 153, 1),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              // const SizedBox(height: 4),
                              Text(
                                widget.topLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(2, 84, 100, 1),
                                ),
                              ),
                              // const SizedBox(height: 2),
                              // Text(
                              //   '(${widget.topValue.toStringAsFixed(2)}% terdeteksi)',
                              //   style: GoogleFonts.plusJakartaSans(
                              //     fontSize: 15, // Sedikit lebih besar
                              //     fontWeight: FontWeight.normal,
                              //     color: Colors.black54,
                              //   ),
                              // ),
                              // const SizedBox(height: 10),
                              // const Divider(height: 24, thickness: 0.5),
                              // Text(
                              //   'Detail Persentase Lainnya:',
                              //   style: GoogleFonts.plusJakartaSans(
                              //       fontSize: 14,
                              //       color: Colors.grey.shade700,
                              //       fontWeight: FontWeight.w500),
                              // ),
                              // const SizedBox(height: 4),
                              // ...results
                              //     .where((result) =>
                              //         result['label'] !=
                              //         widget
                              //             .topLabel) // Tampilkan yang bukan topLabel
                              //     .map((result) => _buildResultRow(
                              //         result['label'] as String,
                              //         result['value'] as double,
                              //         context)),
                            ],
                          ),
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            // Untuk ikon dan tanggal
                            children: [
                              // Icon(
                              //   Icons.calendar_today_outlined,
                              //   size: 14,
                              //   color: Colors.grey.shade600,
                              // ),
                              Text(
                                'Tanggal deteksi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(108, 145, 153, 1),
                                ),
                              ),
                              // const SizedBox(height: 6),
                              Text(
                                dateNow,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(2, 84, 100, 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          _buildDiseaseSpecificInfo(context, widget.topLabel),
                    ),
                  ),
                  const SizedBox(height: 24), // Tambahan spasi sebelum tombol
                ],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Kembali ke Beranda',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Spasi antar tombol
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveDetectionResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Simpan Hasil',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
