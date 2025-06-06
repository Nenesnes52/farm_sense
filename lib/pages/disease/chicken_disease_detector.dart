import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:farm_sense/pages/disease/classification_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Ditambahkan untuk styling

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
  late Interpreter _interpreter;
  bool _isProcessing = false;
  final int _inputSize = 224;

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
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/chicken_disease.tflite', // Pastikan path ini benar
        options: InterpreterOptions()..threads = 4,
      );
      if (kDebugMode) {
        print("Model berhasil dimuat.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Gagal memuat model: $e");
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  Future<void> _processImage(File imageFile) async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
// Simpan untuk ditampilkan
    });

    try {
      // Decode & resize ke _inputSize x _inputSize
      final originalImage = img.decodeImage(await imageFile.readAsBytes());
      if (originalImage == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      final resizedImage =
          img.copyResize(originalImage, width: _inputSize, height: _inputSize);

      // Normalisasi input
      final input = List.generate(
          1,
          (_) => List.generate(
                _inputSize,
                (y) => List.generate(
                  _inputSize,
                  (x) {
                    final pixel =
                        resizedImage.getPixel(x, y); // Mengambil objek Pixel
                    return [
                      pixel.r / 255.0, // Mengakses komponen merah
                      pixel.g / 255.0, // Mengakses komponen hijau
                      pixel.b / 255.0 // Mengakses komponen biru
                    ];
                  },
                ),
              ));

      // Prediksi
      final output = List.filled(1 * 4, 0.0)
          .reshape([1, 4]); // Sesuaikan dengan jumlah kelas output model Anda
      _interpreter.run(input, output);

      final predictionResult = (output[0] as List).cast<double>();

      // Mendapatkan semua label
      final allLabels = _getLabels();

      double coccidiosisPercentage = 0.0;
      double sehatPercentage = 0.0;
      double newcastlePercentage = 0.0;
      double salmonellaPercentage = 0.0;
      String topPredictionLabel = '';
      double topPredictionValue = 0.0;

      List<Map<String, dynamic>> resultsForSorting = [];

      for (int i = 0; i < predictionResult.length; i++) {
        String label = allLabels[i];
        double percentage = predictionResult[i] * 100;

        resultsForSorting.add({'label': label, 'value': percentage});

        if (label == "Coccidiosis") {
          coccidiosisPercentage = percentage;
        } else if (label == "Sehat") {
          sehatPercentage = percentage;
        } else if (label == "Newcastle Disease") {
          newcastlePercentage = percentage;
        } else if (label == "Salmonella") {
          salmonellaPercentage = percentage;
        }
      }

      // Mengurutkan untuk menentukan prediksi utama (opsional jika hanya butuh variabel terpisah)
      resultsForSorting.sort(
          (a, b) => (b['value'] as double).compareTo(a['value'] as double));
      if (resultsForSorting.isNotEmpty) {
        topPredictionLabel = resultsForSorting[0]['label'] as String;
        topPredictionValue = resultsForSorting[0]['value'] as double;
      }

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ClassificationResult(
              // Teruskan variabel-variabel individual
              coccidiosis: coccidiosisPercentage,
              sehat: sehatPercentage,
              newcastle: newcastlePercentage,
              salmonella: salmonellaPercentage,
              topLabel: topPredictionLabel, // Label prediksi tertinggi
              topValue: topPredictionValue, // Persentase prediksi tertinggi
              processedImageFile: imageFile,
            );
          },
        ));
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error processing image: $e");
      }
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  List<String> _getLabels() {
    // Helper untuk mendapatkan semua label
    return [
      "Coccidiosis",
      "Sehat",
      "Newcastle Disease",
      "Salmonella",
    ];
  }

  Future<void> _captureAndProcessImage() async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
// Kosongkan hasil sebelumnya
// Kosongkan gambar preview hasil sebelumnya
      });

      // Pastikan controller sudah terinisialisasi
      await _initControllerFuture;

      final image = await _controller.takePicture();

      final originalBytes = await File(image.path).readAsBytes();
      final originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        throw Exception("Gagal decode gambar");
      }

      // Crop menjadi persegi (square) dari tengah
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

      // Simpan gambar yang sudah dicrop sementara
      final tempDir = Directory.systemTemp;
      final croppedFile = File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_cropped.jpg')
        ..writeAsBytesSync(img.encodeJpg(croppedImage, quality: 100));

      if (!mounted) return;

      // Tampilkan dialog konfirmasi
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
        // Jika pengguna memilih "Ambil Ulang" atau menutup dialog
        setState(() {
          _isProcessing = false;
          // _result = 'Pengambilan gambar dibatalkan.';
        });
        // Hapus file crop sementara jika tidak jadi diproses
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deteksi Penyakit Ayam', style: GoogleFonts.poppins()),
        backgroundColor: Color.fromRGBO(7, 135, 160, 1),
        foregroundColor: Colors.white,
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
                    // Jika Future selesai, tampilkan preview.
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio > 0
                            ? 1 / _controller.value.aspectRatio
                            : 1.0, // Sesuaikan aspect ratio
                        child: CameraPreview(_controller),
                      ),
                    );
                  } else {
                    // Jika tidak, tampilkan loading indicator.
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
                  backgroundColor: Theme.of(context).primaryColor,
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
