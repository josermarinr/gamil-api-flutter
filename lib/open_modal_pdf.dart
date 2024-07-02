import 'dart:typed_data';

import 'package:casademo/pdf_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'color_styles.dart';

class OpenModalPdf {
  final BuildContext context;
  final String path;
  final Uint8List? pdfData;
  final Color background;
  OpenModalPdf(
      {required this.path, required this.context, this.background = ColorStyles.primary, this.pdfData, });
  void showModal() {
    final zoomTransformationController = TransformationController();

    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Center(
            child: SizedBox(
              child: InteractiveViewer(
                  transformationController: zoomTransformationController,
                  panEnabled: false, // Set it to false to prevent panning.
                  // boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.5,
                  maxScale: 4,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      dragStartBehavior: DragStartBehavior.down,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: TextButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 16,
                                    )),
                              ),
                              Expanded(
                                child: PdfViewWidget(path: path,)
                              ),
                            ],
                          ),
                        ),
                      ))),
            ),
          ),
        );
      },
    );
  }
}
