import 'package:dio/dio.dart';
import '../api_client.dart';

class ChecklistService {
  final Dio _dio = ApiClient().dio;

  /// Submit checklist data to the backend. The exact endpoint may change; currently using POST /checklists
  Future<Response> submitChecklist(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/checklists', data: payload);
    return resp;
  }
}
