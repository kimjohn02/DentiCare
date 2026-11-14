import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Service to handle direct client-side uploads to Cloudinary.
class CloudinaryService {
  static String cloudName = 'pt0hmlpf';
  static String uploadPreset = 'denticare';

  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera and upload directly to Cloudinary.
  /// Returns the secure HTTPS image URL, or null if cancelled/failed.
  static Future<String?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      return await uploadImageBytes(bytes, filename: pickedFile.name);
    } catch (e) {
      debugPrint('Cloudinary pick and upload error: $e');
      return null;
    }
  }

  /// Upload raw image bytes to Cloudinary using an unsigned upload preset.
  static Future<String?> uploadImageBytes(
    Uint8List bytes, {
    String filename = 'upload.jpg',
  }) async {
    if (cloudName == 'YOUR_CLOUD_NAME' || uploadPreset == 'YOUR_UPLOAD_PRESET') {
      debugPrint(
        'Warning: Cloudinary credentials not set. Please set CloudinaryService.cloudName and uploadPreset.',
      );
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: filename,
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? secureUrl = data['secure_url'];
        return secureUrl;
      } else {
        debugPrint(
          'Cloudinary upload failed: [${response.statusCode}] ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload exception: $e');
      return null;
    }
  }
}

