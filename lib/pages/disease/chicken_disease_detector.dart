import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:farm_sense/pages/disease/classification_result.dart';
import 'package:flutter/foundation.dart';
import 'package:farm_sense/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
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
        'assets/models/chicken_disease_v6_new_default_no_opt.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      if (kDebugMode) {
        print("Model berhasil dimuat.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Gagal memuat model: $e");
      }
      // Pertimbangkan untuk menampilkan pesan error ke pengguna jika model gagal dimuat
      // showErrorDialog(context: context, message: "Gagal memuat model AI", description: e.toString());
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
    });

    try {
      // Decode & resize ke _inputSize x _inputSize
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        if (kDebugMode) {
          print("Gagal decode gambar.");
        }
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      final resizedImage =
          img.copyResize(originalImage, width: _inputSize, height: _inputSize);

      // --- PERUBAHAN UTAMA DI SINI: Normalisasi input ---
      // Model EfficientNet yang dilatih dengan bobot ImageNet dan menggunakan
      // `preprocess_input` biasanya mengharapkan input dalam rentang [-1, 1].
      // `preprocess_input` melakukan (pixel / 127.5) - 1.0
      // Kita juga perlu memastikan urutan channel RGB dan struktur data input sesuai.
      // TFLite Interpreter biasanya mengharapkan Float32List.

      var inputBuffer = Float32List(1 * _inputSize * _inputSize * 3);
      int bufferIndex = 0;
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          var pixel = resizedImage.getPixel(x, y);
          // Normalisasi ke rentang [-1, 1]
          // inputBuffer[bufferIndex++] = (pixel.r / 127.5) - 1.0;
          // inputBuffer[bufferIndex++] = (pixel.g / 127.5) - 1.0;
          // inputBuffer[bufferIndex++] = (pixel.b / 127.5) - 1.0;
          inputBuffer[bufferIndex++] =
              pixel.r.toDouble(); // Gunakan nilai piksel asli
          inputBuffer[bufferIndex++] =
              pixel.g.toDouble(); // Gunakan nilai piksel asli
          inputBuffer[bufferIndex++] =
              pixel.b.toDouble(); // Gunakan nilai piksel asli
        }
      }
      // Reshape buffer menjadi bentuk yang diharapkan model [1, height, width, channels]
      final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);

      // Prediksi
      final output = List.filled(
              1 * _getLabels().length, 0.0) // Gunakan _getLabels().length
          .reshape([1, _getLabels().length]); // Gunakan _getLabels().length
      _interpreter.run(input, output);

      final predictionResult = (output[0] as List).cast<double>();
      if (kDebugMode) {
        print("HASIL MENTAH MODEL (Probabilitas): $predictionResult");
      }

      // --- LOGIKA PEMERIKSAAN AMBANG BATAS ---
      const double confidenceThreshold = 0.75;
      final double maxConfidence =
          predictionResult.reduce((curr, next) => curr > next ? curr : next);

      if (maxConfidence < confidenceThreshold) {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
        await showErrorDialog(
          context: context,
          message: "Tidak ada feses terdeteksi",
          description: "Sistem tidak mendeteksi adanya feses pada gambar.",
          solution:
              "\nPastikan feses ayam terlihat jelas, tidak buram, dan berada di tengah kamera.",
        );
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
        return;
      }

      // --- AKHIR DARI LOGIKA PEMERIKSAAN ---

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
              coccidiosis: coccidiosisPercentage,
              sehat: sehatPercentage,
              newcastle: newcastlePercentage,
              salmonella: salmonellaPercentage,
              topLabel: topPredictionLabel,
              topValue: topPredictionValue,
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
      // Pertimbangkan untuk menampilkan dialog error kepada pengguna di sini juga
      // await showErrorDialog(
      //   context: context,
      //   message: "Terjadi Kesalahan",
      //   description: "Gagal memproses gambar. Silakan coba lagi.",
      // );
    }
  }

  List<String> _getLabels() {
    // Helper untuk mendapatkan semua label
    // Pastikan urutan ini SAMA PERSIS dengan urutan output model Anda
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
