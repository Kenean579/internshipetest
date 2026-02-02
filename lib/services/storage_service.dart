import 'dart:io';
import 'package:http/http.dart' as http;

class StorageService {
  static const String _catboxUrl = 'https://catbox.moe/user/api.php';

  Future<String> uploadImage(File file, String folder) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_catboxUrl));
      request.fields['reqtype'] = 'fileupload';
      request.files.add(
        await http.MultipartFile.fromPath('fileToUpload', file.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return responseBody.trim();
      } else {
        throw 'Failed to upload image. Status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }
}
