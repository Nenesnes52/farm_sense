import 'dart:io'; // Diperlukan untuk File
import 'package:camera/camera.dart';
import 'package:farm_sense/pages/disease/chicken_disease_detector.dart';
import 'package:flutter/foundation.dart'; // Diperlukan untuk kDebugMode
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img; // Package untuk manipulasi gambar
import 'package:tflite_flutter/tflite_flutter.dart'; // Package TFLite

// Import halaman hasil klasifikasi Anda
import 'package:farm_sense/pages/disease/classification_result.dart'; // Sesuaikan path jika berbeda

class MainMenu extends StatefulWidget {
  const MainMenu({
    this.initPageIndex,
    super.key,
  });

  final int? initPageIndex;
  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  // Variabel untuk TFLite dan proses gambar
  Interpreter?
      _interpreter; // Dijadikan nullable, akan diinisialisasi di _loadModel
  final int _inputSize = 224;
  bool _isProcessing = false; // Untuk loading indicator jika diperlukan

  // Variabel lain yang sudah ada
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _loadModel(); // Muat model TFLite saat initState
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/chicken_disease.tflite', // Pastikan path ini benar
        options: InterpreterOptions()..threads = 4,
      );
      if (kDebugMode) {
        print("Model TFLite berhasil dimuat dari MainMenu.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Gagal memuat model TFLite dari MainMenu: $e");
      }
      // Tambahkan penanganan error jika diperlukan, misal menampilkan SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal memuat model AI. Fitur deteksi mungkin tidak berfungsi.")),
        );
      }
    }
  }

  List<String> _getLabels() {
    // Label harus sesuai dengan urutan output model Anda
    return [
      "Coccidiosis",
      "Sehat",
      "Newcastle Disease",
      "Salmonella",
    ];
  }

  Future<void> _pickImageFromGallery() async {
    if (_interpreter == null) {
      if (kDebugMode) {
        print("Interpreter TFLite belum siap.");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Model AI belum siap, coba lagi nanti.")),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100, // Kualitas gambar terbaik
    );

    if (pickedFile == null) return; // User membatalkan pemilihan

    // Crop gambar
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Crop 1:1
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Potong Gambar',
          toolbarColor: Theme.of(context).primaryColor, // Sesuaikan warna
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true, // Kunci rasio aspek 1:1
        ),
        IOSUiSettings(
          title: 'Potong Gambar',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          doneButtonTitle: 'Selesai',
          cancelButtonTitle: 'Batal',
        ),
      ],
    );

    if (croppedFile == null) return; // User membatalkan cropping

    final File imageFile = File(croppedFile.path);

    setState(() {
      _isProcessing = true; // Mulai proses, tampilkan loading jika ada
    });

    try {
      // Decode, resize ke _inputSize x _inputSize, dan normalisasi
      final originalImageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(originalImageBytes);

      if (originalImage == null) {
        throw Exception("Gagal membaca gambar setelah di-crop.");
      }

      final img.Image resizedImage =
          img.copyResize(originalImage, width: _inputSize, height: _inputSize);

      final input = List.generate(
          1,
          (_) => List.generate(
                _inputSize,
                (y) => List.generate(
                  _inputSize,
                  (x) {
                    final pixel = resizedImage.getPixel(x, y);
                    return [
                      pixel.r / 255.0, // Akses komponen merah (sudah dikoreksi)
                      pixel.g / 255.0, // Akses komponen hijau
                      pixel.b / 255.0 // Akses komponen biru
                    ];
                  },
                ),
              ));

      // Prediksi
      // Pastikan output shape sesuai dengan model Anda (misal 1x4 untuk 4 kelas)
      final output = List.filled(1 * 4, 0.0).reshape([1, 4]);
      _interpreter!
          .run(input, output); // Gunakan _interpreter! karena sudah dicek null

      final predictionResult = (output[0] as List).cast<double>();
      final allLabels = _getLabels();

      // Ekstrak hasil ke variabel individual seperti di chicken_disease_detector.dart
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

      if (mounted) {
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
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing image from gallery: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Terjadi kesalahan saat memproses gambar: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false; // Selesai proses
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    // ... (kode _onWillPop Anda tidak berubah) ...
    DateTime now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 3)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tekan sekali lagi untuk keluar"),
          backgroundColor: Colors.black45.withValues(alpha: 0.7),
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _interpreter?.close(); // Tutup interpreter jika tidak null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        // ... (Dekorasi Container Anda tidak berubah) ...
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 0.39],
            colors: [
              Color.fromRGBO(2, 84, 100, 1),
              Color.fromRGBO(91, 158, 172, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo_image.png',
                        height: 150,
                        width: 150,
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(2, 77, 91, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ... (Widget Riwayat Terakhir Anda tidak berubah) ...
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      'Riwayat Terakhir',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 32,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text('4 Juni 2025'),
                                    Text('Terdeteksi Salmonella'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              // ... (Widget Riwayat Hasil Deteksi Anda tidak berubah) ...
                              Semantics(
                                button: true,
                                child: GestureDetector(
                                  onTap: () {
                                    // Tambahkan navigasi ke halaman riwayat jika ada
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Riwayat Hasil Deteksi',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Image.asset('assets/images/history.png')
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _isProcessing
                                          ? null
                                          : _pickImageFromGallery, // Panggil fungsi di sini
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Unggah Gambar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(
                                                height: _isProcessing ? 10 : 0),
                                            _isProcessing
                                                ? CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/upload.png',
                                                    height: 90,
                                                    width: 90,
                                                  )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        // Fungsi Ambil Gambar tetap sama
                                        // ... (kode onTap Ambil Gambar Anda tidak berubah) ...
                                        final camerasAvailable =
                                            await availableCameras();
                                        if (camerasAvailable.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Tidak ada kamera tersedia.")),
                                          );
                                          return;
                                        }
                                        final firstCamera =
                                            camerasAvailable.firstWhere(
                                          (camera) =>
                                              camera.lensDirection ==
                                              CameraLensDirection.back,
                                          orElse: () => camerasAvailable
                                              .first, // Fallback jika tidak ada kamera belakang
                                        );

                                        if (context.mounted) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ChickenDiseaseDetector(
                                                // Halaman ini tetap untuk ambil gambar via kamera
                                                camera: firstCamera,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        // ... (Container Ambil Gambar Anda tidak berubah) ...
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Ambil Gambar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/images/capture.png',
                                              height: 90,
                                              width: 90,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
