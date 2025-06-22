import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:farm_sense/helpers/classifier.dart';
import 'package:farm_sense/pages/disease/classification_result.dart';
import 'package:flutter/foundation.dart';
import 'package:farm_sense/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';

class ChickenDiseaseDetector extends StatefulWidget {
  final CameraDescription camera;

  const ChickenDiseaseDetector({
    required this.camera,
    super.key,
  });

  @override
  State<ChickenDiseaseDetector> createState() => _ChickenDiseaseDetectorState();
}

class _ChickenDiseaseDetectorState extends State<ChickenDiseaseDetector> {
  // HANYA PERLU SATU INSTANCE CLASSIFIER
  final Classifier _classifier = Classifier();
  bool _isProcessing = false;

  late CameraController _controller;
  late Future<void> _initControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _initControllerFuture = _controller.initialize();
    // Muat model melalui classifier
    _classifier.loadModel();
  }

  @override
  void dispose() {
    _controller.dispose();
    _classifier.dispose();
    super.dispose();
  }

// Di dalam file: lib/pages/disease/chicken_disease_detector.dart
// Ganti method _processImage dengan ini

  Future<void> _processImage(File imageFile) async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final PredictionResult? result =
          await _classifier.processImage(imageFile);

      if (result == null) {
        throw Exception("Gagal memproses gambar dengan classifier.");
      }

      // --- LOGIKA AMBANG BATAS GANDA (DUAL THRESHOLD) BARU ---
      const double validityThreshold =
          0.50; // Ambang batas minimal 50% untuk dianggap valid
      const double diseaseAlertThreshold =
          0.70; // Ambang batas 70% untuk peringatan penyakit

      // 1. Cek validitas gambar secara umum
      if (result.topConfidence < validityThreshold) {
        if (mounted) {
          await showErrorDialog(
            context: context,
            message: "Gambar Tidak Dapat Diproses",
            description:
                "Sistem tidak dapat mengenali objek dengan keyakinan yang cukup.",
            solution:
                "\nPastikan feses ayam terlihat jelas, tidak buram, dan berada di tengah kamera.",
          );
        }
        return; // Hentikan eksekusi
      }

      // 2. Cek jika prediksi adalah penyakit dengan keyakinan sedang
      if (result.topLabel != 'Sehat' &&
          result.topConfidence < diseaseAlertThreshold) {
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return ClassificationResult(
                coccidiosis: result.allScores['Coccidiosis']! * 100,
                sehat: result.allScores['Sehat']! * 100,
                newcastle: result.allScores['Newcastle Disease']! * 100,
                salmonella: result.allScores['Salmonella']! * 100,
                topLabel: result.topLabel,
                topValue: result.topConfidence * 100,
                processedImageFile: imageFile,
                // Tambahkan catatan khusus untuk keyakinan rendah
                customNote:
                    "PERINGATAN: Gejala terdeteksi dengan tingkat keyakinan sedang. Disarankan untuk melakukan observasi lebih lanjut atau melakukan tes ulang dengan gambar yang lebih jelas.",
              );
            },
          ));
        }
        return; // Hentikan eksekusi agar tidak lanjut ke navigasi di bawah
      }

      // 3. Jika lolos semua, navigasi seperti biasa (untuk prediksi 'Sehat' atau penyakit > 70%)
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ClassificationResult(
              coccidiosis: result.allScores['Coccidiosis']! * 100,
              sehat: result.allScores['Sehat']! * 100,
              newcastle: result.allScores['Newcastle Disease']! * 100,
              salmonella: result.allScores['Salmonella']! * 100,
              topLabel: result.topLabel,
              topValue: result.topConfidence * 100,
              processedImageFile: imageFile,
            );
          },
        ));
      }
    } catch (e) {
      if (kDebugMode) print("Error processing image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Terjadi kesalahan saat memproses gambar: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _captureAndProcessImage() async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      await _initControllerFuture;
      final image = await _controller.takePicture();
      final originalBytes = await File(image.path).readAsBytes();
      final originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        throw Exception("Gagal decode gambar");
      }

      final width = originalImage.width;
      final height = originalImage.height;
      final size = width < height ? width : height;
      final offsetX = (width - size) ~/ 2;
      final offsetY = (height - size) ~/ 2;

      final croppedImage = img.copyCrop(
        originalImage,
        x: offsetX,
        y: offsetY,
        width: size,
        height: size,
      );

      final tempDir = Directory.systemTemp;
      final croppedFile = File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_cropped.jpg')
        ..writeAsBytesSync(img.encodeJpg(croppedImage, quality: 100));

      if (!mounted) return;

      final confirmProcess = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pratinjau Gambar',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(croppedFile,
                      fit: BoxFit.cover, height: 250, width: 250),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Batal
                      },
                      child: Text('Kembali',
                          style: GoogleFonts.poppins(color: Colors.red)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(true); // Konfirmasi
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label:
                          Text('Proses Gambar', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );

      if (confirmProcess == true) {
        await _processImage(croppedFile);
      } else {
        setState(() {
          _isProcessing = false;
        });
        if (await croppedFile.exists()) {
          await croppedFile.delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in _captureAndProcessImage: $e');
      }
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      // Pertimbangkan untuk menampilkan dialog error kepada pengguna di sini juga
      // await showErrorDialog(
      //   context: context,
      //   message: "Terjadi Kesalahan",
      //   description: "Gagal mengambil atau memproses gambar. Silakan coba lagi.",
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SvgPicture.asset(
            'assets/images/back-icon.svg', // Pastikan path ini benar
            fit: BoxFit.none,
          ),
        ),
        title: Text(
          'Deteksi Penyakit Ayam',
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FutureBuilder<void>(
                future: _initControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio > 0
                            ? 1 / _controller.value.aspectRatio
                            : 1.0,
                        child: CameraPreview(_controller),
                      ),
                    );
                  } else {
                    return const Center(
                        heightFactor: 5, child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: _isProcessing
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(_isProcessing ? 'Memproses...' : 'Ambil Gambar',
                    style: GoogleFonts.poppins(fontSize: 16)),
                onPressed: _isProcessing ? null : _captureAndProcessImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Color.fromRGBO(23, 132, 204, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
