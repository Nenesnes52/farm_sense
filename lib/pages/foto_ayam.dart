import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class FotoAyamPage extends StatefulWidget {
  const FotoAyamPage({
    required this.camera,
    super.key,
  });
  final CameraDescription camera;
  @override
  State<FotoAyamPage> createState() => _FotoAyamPageState();
}

class _FotoAyamPageState extends State<FotoAyamPage> {
  late CameraController _controller;
  late Future<void> _initControllerFuture;
  bool isVerifying = false;
  double healthyValue = 0;
  double coccidiosisValue = 0;
  double newCastleValue = 0;
  double salmonellaValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _initControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final mediaSize = MediaQuery.of(context).size;
    // final scale = 1 / (_controller.value.aspectRatio * mediaSize.aspectRatio);
    // final scale = 1 /
    //     (_controller.value.aspectRatio *
    //         MediaQuery.of(context).size.aspectRatio);
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        // child: Text("s"),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<void>(
                future: _initControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              IconButton(
                onPressed: () async {
                  // setState(() {
                  //   Navigator.of(context).pop();
                  //   // Navigator.of(context).pushReplacement(
                  //   //   MaterialPageRoute(
                  //   //     builder: (context) => const MainPage(
                  //   //       initPageIdx: 1,
                  //   //     ),
                  //   //   ),
                  //   // );
                  // });
                  try {
                    setState(() {
                      isVerifying = true;
                    });
                    setState(() {
                      isVerifying = true;
                    });
                    // Ensure that the camera is initialized.
                    // await _initControllerFuture;

                    // Attempt to take a picture and get the file `image`
                    // where it was saved.
                    final image = await _controller.takePicture();
                    final path = image.path;
                    final bytes = File(path).readAsBytesSync();
                    print('##############$bytes.last');

                    final uri = Uri.parse(
                        'http://api.zonainovasi.site/vision/compute/zona-farm-vision');
                    var request = http.MultipartRequest('POST', uri);
                    final httpImage = http.MultipartFile.fromBytes(
                      'to-compute',
                      bytes,
                      // contentType: MediaType.parse(mimeType),
                      filename: 'ShittyImage.png',
                    );
                    request.files.add(httpImage);
                    final streamedResponse = await request.send();
                    final response =
                        await http.Response.fromStream(streamedResponse);
                    print(response.body);
                    var jsonResponse = convert.jsonDecode(response.body)
                        as Map<String, dynamic>;

                    final healthy = jsonResponse['Healthy'];
                    final coccidiosis = jsonResponse['Coccidiosis'];
                    final newCastle = jsonResponse['New Castle Disease'];
                    final salmonella = jsonResponse['Salmonella'];

                    if (healthy != null) healthyValue = healthy;
                    if (coccidiosis != null) coccidiosisValue = coccidiosis;
                    if (newCastle != null) newCastleValue = newCastle;
                    if (salmonella != null) salmonellaValue = salmonella;

                    print('${response.statusCode}');
                    if (response.statusCode > 400) {
                      setState(() {
                        AlertDialog(
                          title: Text(
                              'Pengambilan gambar gagal, silakan coba lagi'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'))
                          ],
                        );

                        // final snackBar = SnackBar(
                        //   content: Text(
                        //       'Error ${response.statusCode}, silakan coba lagi'),
                        // );
                        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    } else {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Column(
                              children: [
                                Text('Result'),
                                Text(
                                    'Healthy: ${(healthyValue * 100).toStringAsFixed(2)}%'),
                                Text(
                                    'Coccidiosis: ${(coccidiosisValue * 100).toStringAsFixed(2)}%'),
                                Text(
                                    'New Castle: ${(newCastleValue * 100).toStringAsFixed(2)}%'),
                                Text(
                                    'Salmonella: ${(salmonellaValue * 100).toStringAsFixed(2)}%'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: Text('OK'))
                            ],
                          ),
                        );

                        // final snackBar = SnackBar(
                        //   content: Text('Image upload ${response.body}'),
                        // );
                        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // Navigator.of(context).pop();
                      }
                    }

                    isVerifying = false;
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                },
                icon: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(2, 84, 100, 1),
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(
                    //   color: Color.fromRGBO(0, 35, 125, 1),
                    // ),
                  ),
                  child: isVerifying
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Ambil Gambar',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white),
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
