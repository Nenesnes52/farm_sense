import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionResult {
  final String topLabel;
  final double topConfidence;
  final Map<String, double> allScores;

  PredictionResult({
    required this.topLabel,
    required this.topConfidence,
    required this.allScores,
  });
}

class Classifier {
  Interpreter? _interpreter;
  final List<String> _labels = [
    "Coccidiosis",
    "Sehat",
    "Newcastle Disease",
    "Salmonella",
  ];
  final int _inputSize = 224;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    if (_isModelLoaded) {
      if (kDebugMode) print("Model sudah dimuat sebelumnya.");
      return;
    }
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/resnet18_final_model.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      _isModelLoaded = true;
      if (kDebugMode) {
        print("✅ Model TFLite berhasil dimuat.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Gagal memuat model TFLite: $e");
      }
    }
  }

  Future<PredictionResult?> processImage(File imageFile) async {
    if (_interpreter == null) {
      if (kDebugMode) print("Model belum dimuat. Coba muat lagi.");
      await loadModel();
      if (_interpreter == null) return null;
    }

    try {
      // Pra-pemrosesan gambar (kode ini sudah benar)
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      img.Image rgbImage;
      if (originalImage.numChannels != 3) {
        rgbImage =
            img.Image(width: originalImage.width, height: originalImage.height);
        for (int y = 0; y < originalImage.height; y++) {
          for (int x = 0; x < originalImage.width; x++) {
            final pixel = originalImage.getPixel(x, y);
            rgbImage.setPixelRgb(
                x, y, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
          }
        }
      } else {
        rgbImage = originalImage;
      }
      final resizedImage =
          img.copyResize(rgbImage, width: _inputSize, height: _inputSize);

      var imageMatrix = List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            var pixel = resizedImage.getPixel(x, y);
            return [
              (pixel.rNormalized - 0.485) / 0.229,
              (pixel.gNormalized - 0.456) / 0.224,
              (pixel.bNormalized - 0.406) / 0.225,
            ];
          },
        ),
      );

      final input = [imageMatrix];
      final output =
          List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      _interpreter!.run(input, output);

      final logits = (output[0] as List).cast<double>();
      if (kDebugMode) {
        print("HASIL MENTAH MODEL (Logits): $logits");
      }

      // --- PERBAIKAN FINAL: TERAPKAN SOFTMAX UNTUK MENDAPATKAN PROBABILITAS ---
      final List<double> probabilities = _applySoftmax(logits);
      if (kDebugMode) {
        print("HASIL SETELAH SOFTMAX (Probabilitas): $probabilities");
      }

      // Cari probabilitas tertinggi
      double maxProb = 0.0;
      int maxIndex = -1;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }
      if (maxIndex == -1) return null;

      // Buat map dari semua skor probabilitas
      Map<String, double> allScores = {};
      for (int i = 0; i < _labels.length; i++) {
        allScores[_labels[i]] = probabilities[i];
      }

      // Kembalikan probabilitas sebagai topConfidence
      return PredictionResult(
        topLabel: _labels[maxIndex],
        topConfidence: maxProb, // <-- INI SEKARANG PROBABILITAS (0.0 - 1.0)
        allScores: allScores,
      );
    } catch (e, s) {
      if (kDebugMode) {
        print("❌ TERJADI ERROR DI DALAM processImage: $e");
        print("Stack trace: $s");
      }
      return null;
    }
  }

  // --- FUNGSI BARU UNTUK SOFTMAX ---
  List<double> _applySoftmax(List<double> logits) {
    double maxLogit = logits.reduce(max);
    final exps = logits.map((logit) => exp(logit - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
    if (kDebugMode) print("Interpreter ditutup.");
  }
}
