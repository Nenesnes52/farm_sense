import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Timestamp
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetectionHistoryDetail extends StatelessWidget {
  final Map<String, dynamic> detectionData;

  const DetectionHistoryDetail({super.key, required this.detectionData});

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

  @override
  Widget build(BuildContext context) {
    final String topLabel = detectionData['topLabel'] ?? 'Tidak Diketahui';
    final String detectionDate =
        detectionData['detectionDate'] ?? 'Tanggal Tidak Ada';
    final String detectionTime =
        detectionData['detectionTime'] ?? 'Waktu Tidak Ada';

    String formattedDateTime;
    if (detectionData['timestamp'] != null &&
        detectionData['timestamp'] is Timestamp) {
      DateTime dt = (detectionData['timestamp'] as Timestamp).toDate();
      formattedDateTime =
          DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id_ID').format(dt);
    } else {
      formattedDateTime = '$detectionDate, $detectionTime';
    }

    final Color primaryColor = Color.fromRGBO(23, 132, 204, 1);
    final Color secondaryColor = Color.fromRGBO(11, 66, 102, 1);
    final Color cardContentColor = Color.fromRGBO(23, 132, 204, 1);

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
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        title: Text(
          'Detail Riwayat',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 4, // Naikkan elevasi agar bayangan lebih terlihat
              margin: EdgeInsets.zero, // Hapus margin default dari Card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Atur radius sudut
              ),
              clipBehavior: Clip.antiAlias, // Penting untuk memotong child
              child: Column(
                children: [
                  // --- BAGIAN KONTEN PUTIH ---
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 24), // Beri padding bawah lebih
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            formattedDateTime,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Terdeteksi $topLabel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: cardContentColor),
                          ),
                          const Divider(
                            height: 30,
                            thickness: 0.7,
                            indent: 5,
                            endIndent: 5,
                          ),
                          _buildDiseaseSpecificInfo(context, topLabel),
                        ],
                      ),
                    ),
                  ),
                  // --- BAGIAN SLOGAN BIRU ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Ayam Prima, Peternak Jaya!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
