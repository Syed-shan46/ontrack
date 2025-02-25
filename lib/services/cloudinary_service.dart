import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  Future<String> uploadImage(Uint8List file) async {
    String cloudName = 'dagq3j3dp';
    String uploadPreset = 'fwejxnfu';
    String apiUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    // Encode the image to base64
    String base64Image = base64Encode(file);

    // Create the request body
    var requestBody = {
      'file': 'data:image/png;base64,$base64Image',
      'upload_preset': uploadPreset,
    };

    // Send the POST request
    var response = await http.post(
      Uri.parse(apiUrl),
      body: requestBody,
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }
}
