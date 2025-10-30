import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../api_client.dart';

class UploadService {
  final Dio _dio = ApiClient().dio;

  /// Upload a single file (bytes) with a filename. Returns the file URL on success.
  Future<String> uploadBytes(Uint8List bytes, String filename) async {
    return uploadBytesWithProgress(bytes, filename, null);
  }

  /// Upload with progress callback (sent, total)
  Future<String> uploadBytesWithProgress(
    Uint8List bytes,
    String filename,
    void Function(int sent, int total)? onSendProgress, {
    CancelToken? cancelToken,
  }) async {
    final form = FormData();
    final contentTypeStr =
        MediaTypeParser.getContentTypeFromFilename(filename) ??
        'application/octet-stream';
    final mtParts = contentTypeStr.split('/');
    final mediaType = MediaType(
      mtParts[0],
      mtParts.length > 1 ? mtParts[1] : 'octet-stream',
    );
    form.files.add(
      MapEntry(
        'file',
        MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: mediaType,
        ),
      ),
    );

    final resp = await _dio.post(
      '/uploads',
      data: form,
      onSendProgress: onSendProgress,
      options: Options(headers: {'content-type': 'multipart/form-data'}),
      cancelToken: cancelToken,
    );
    // Expect backend returns { data: { url: '...' } } or { url: '...' }
    if (resp.data is Map) {
      final data = resp.data as Map;
      if (data['data'] is Map && data['data']['url'] != null)
        return data['data']['url'];
      if (data['url'] != null) return data['url'];
    }
    throw Exception('Upload failed');
  }
}

/// Small helper to parse content-type from filename extension (simple)
class MediaTypeParser {
  static String? getContentTypeFromFilename(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
