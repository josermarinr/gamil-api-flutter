import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';


Uint8List decodeBase64Url(String encoded) {
  String normalBase64 = encoded.replaceAll('-', '+').replaceAll('_', '/');
  return base64.decode(normalBase64);
}


Future<String> saveToTempDirectory(String base64UrlEncodedData, String name) async {
  Uint8List data = decodeBase64Url(base64UrlEncodedData);
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}+$name.pdf';
  File file = File(tempPath);
  await file.writeAsBytes(data);
  return tempPath;
}
