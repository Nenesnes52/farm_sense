import 'package:camera/camera.dart';
import 'package:farm_sense/chicken_disease_detector.dart';
import 'package:flutter/material.dart';

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
  CameraDescription? firstCamera;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
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
        child: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Scaffold(
                // resizeToAvoidBottomInset: true,
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
                              GestureDetector(
                                onTap: () {},
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
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {},
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
                                            // SizedBox(height: 10),
                                            Image.asset(
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
                                        final cameras =
                                            (await availableCameras())
                                                .firstWhere((camera) =>
                                                    camera.lensDirection ==
                                                    CameraLensDirection.back);
                                        final firstCamera = cameras;
                                        if (context.mounted) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ChickenDiseaseDetector(
                                                camera: firstCamera,
                                              ),
                                            ),
                                          );
                                        }
                                      },
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
                                              'Ambil Gambar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            // SizedBox(height: 10),
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
