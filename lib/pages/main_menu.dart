import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_sense/routes/route_name.dart';
import 'package:farm_sense/pages/disease/chicken_disease_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:farm_sense/pages/disease/classification_result.dart';

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
  DocumentSnapshot? _latestHistory; // Untuk menyimpan data riwayat terbaru
  bool _isLoadingHistory = true; // Untuk loading indicator riwayat

  // Variabel lain yang sudah ada
  DateTime? _lastBackPressed;

  // GlobalKey untuk Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadModel(); // Muat model TFLite saat initState
    _fetchLatestHistory(); // Ambil riwayat terbaru
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

  Future<void> _fetchLatestHistory() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoadingHistory = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('detection_history')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _latestHistory = querySnapshot.docs.first;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching latest history: $e");
    }
    setState(() {
      _isLoadingHistory = false;
    });
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Model AI belum siap, coba lagi nanti.")),
        );
      }
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
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
          toolbarColor: Theme.of(context).primaryColor,
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

    if (mounted) {
      setState(() {
        _isProcessing = true; // Mulai proses, tampilkan loading jika ada
      });
    }

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
                      pixel.r / 255.0, // Akses komponen merah
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

  Future<void> _openCamera() async {
    final camerasAvailable = await availableCameras();
    if (!mounted) return; // Check if widget is still in the tree

    if (camerasAvailable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak ada kamera tersedia.")),
      );
      return;
    }
    final firstCamera = camerasAvailable.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => camerasAvailable.first,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChickenDiseaseDetector(
          camera: firstCamera,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 3)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tekan sekali lagi untuk keluar"),
          backgroundColor: Colors.black45.withAlpha(178), // 0.7 alpha
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
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
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Scaffold(
              key: _scaffoldKey, // Assign the key to Scaffold
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
              drawer: Drawer(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          DrawerHeader(
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/logo_image.png', // Your logo
                                  height: 120,
                                ),
                                // SizedBox(height: 10),
                                // Text(
                                //   'Farm Sense',
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('Ambil Gambar'),
                            onTap: () {
                              Navigator.pop(context); // Close drawer
                              _openCamera();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Unggah Gambar'),
                            onTap: () {
                              Navigator.pop(context); // Close drawer
                              _pickImageFromGallery();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.history),
                            title: Text('Riwayat Hasil Deteksi'),
                            onTap: () {
                              Navigator.pop(context); // Close drawer
                              Navigator.pushNamed(context, historyRoute);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: () async {
                        Navigator.pop(context); // Close drawer
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          // Make sure 'authRoute' is defined in your route_name.dart
                          // and it leads to your login/authentication page.
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              authRoute, (Route<dynamic> route) => false);
                        }
                      },
                    ),
                    SizedBox(height: 10), // Padding at the bottom
                  ],
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Image.asset(
                          'assets/images/logo_image.png',
                          height: MediaQuery.of(context).size.width * 0.4,
                          width: MediaQuery.of(context).size.width * 0.4,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(2, 77, 91, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width *
                                0.05), // Padding relatif
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width *
                                      0.04), // Padding relatif
                              child: Column(
                                children: [
                                  Text(
                                    'Riwayat Terakhir',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.07, // Ukuran font relatif
                                      color: Color.fromRGBO(2, 84, 100,
                                          1), // Pastikan warna teks konsisten
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  _isLoadingHistory // Widget ini sudah menangani state loading
                                      ? CircularProgressIndicator()
                                      : _latestHistory == null
                                          ? Text('Belum ada riwayat')
                                          : Column(
                                              children: [
                                                Text(
                                                  "${_latestHistory!['detectionDate'] ?? 'N/A'}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color.fromRGBO(
                                                        2, 84, 100, 1),
                                                  ),
                                                ),
                                                Text(
                                                  "${_latestHistory!['topLabel'] ?? 'N/A'}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        2, 84, 100, 1),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Semantics(
                              button: true,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, historyRoute);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      vertical: 10),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Riwayat Hasil Deteksi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          color: Color.fromRGBO(2, 84, 100, 1),
                                        ),
                                        textAlign: TextAlign.center,
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
                                        : _pickImageFromGallery,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                          vertical: 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Unggah Gambar',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.038,
                                              color:
                                                  Color.fromRGBO(2, 84, 100, 1),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                              height: _isProcessing
                                                  ? 10
                                                  : (_isProcessing
                                                      ? 10
                                                      : (MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.18 *
                                                          0.1))), // Dynamic Sizedbox based on image height
                                          _isProcessing
                                              ? Padding(
                                                  // Add padding around indicator
                                                  padding: EdgeInsets.only(
                                                      top: (MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.18 *
                                                          0.3),
                                                      bottom: (MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.18 *
                                                          0.3)),
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/upload.png',
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.18,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.18,
                                                )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        _openCamera, // Use the new _openCamera method
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                          vertical: 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Ambil Gambar',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.038,
                                              color:
                                                  Color.fromRGBO(2, 84, 100, 1),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                              height: (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.18 *
                                                  0.1)), // Dynamic Sizedbox based on image height
                                          Image.asset(
                                            'assets/images/capture.png',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.18,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.18,
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
    );
  }
}
