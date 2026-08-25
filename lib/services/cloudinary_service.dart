import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'c9wllstn';
  static const String uploadPreset = 'diario-fotos';

  static Uri get _uploadUrl => Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// Uploads a local image file and returns the public URL Cloudinary gives back.
  /// Throws an [Exception] with a readable message if the upload fails.
  static Future<String> uploadImage(File file) async {
    final request = http.MultipartRequest('POST', _uploadUrl)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('No se pudo subir la foto (${response.statusCode}). Comprueba el cloud name y el upload preset.');
    }

    final bodyText = response.body;
    final decoded = jsonDecode(bodyText) as Map<String, dynamic>;
    final url = decoded['secure_url'] as String?;
    if (url == null) {
      throw Exception('Cloudinary respondió sin una URL de imagen válida.');
    }
    return url;
  }
}
