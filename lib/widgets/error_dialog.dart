import 'package:flutter/material.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String message,
  String? description,
  String? solution,
  bool isWarning = false,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.2
                      ..color = isWarning
                          ? Colors.yellow
                          : Color.fromRGBO(245, 53, 48, 1),
                  ),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isWarning
                        ? Colors.yellow
                        : Color.fromRGBO(245, 53, 48, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (description != null)
              Text(
                description,
                softWrap: true,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            if (solution != null) ...[
              Text(
                solution,
                softWrap: true,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
            const SizedBox(height: 5),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromRGBO(2, 84, 100, 1),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
