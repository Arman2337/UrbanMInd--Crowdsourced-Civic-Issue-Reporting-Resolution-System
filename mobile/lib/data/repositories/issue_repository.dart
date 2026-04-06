import '../models/issue_model.dart';
import '../network/api_service.dart';
import '../../core/utils/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IssueRepository {
  final ApiService _apiService = ApiService();

  Future<List<Issue>> getMyIssues() async {
    final response = await _apiService.get(AppConstants.issuesMyEndpoint);
    if (response is List) {
      return response.map((data) => Issue.fromJson(data)).toList();
    } else if (response != null && response['data'] != null) {
      return (response['data'] as List)
          .map((data) => Issue.fromJson(data))
          .toList();
    } else if (response != null && response['issues'] != null) {
      return (response['issues'] as List)
          .map((data) => Issue.fromJson(data))
          .toList();
    }
    return [];
  }

  Future<List<Issue>> getAllIssues() async {
    final response = await _apiService.get(AppConstants.issuesAllEndpoint);
    if (response is List) {
      return response.map((data) => Issue.fromJson(data)).toList();
    } else if (response != null && response['data'] != null) {
      return (response['data'] as List)
          .map((data) => Issue.fromJson(data))
          .toList();
    } else if (response != null && response['issues'] != null) {
      return (response['issues'] as List)
          .map((data) => Issue.fromJson(data))
          .toList();
    }
    return [];
  }

  Future<void> createIssue({
    required String title,
    required String description,
    required String category,
    required double lat,
    required double lng,
    required String address,
    required List<String>
    imagePaths, // Can be local file paths for multipart upload
  }) async {
    // If we have images, we need multipart request, otherwise normal post
    if (imagePaths.isEmpty) {
      await _apiService.post(AppConstants.issuesCreateEndpoint, {
        'title': title,
        'description': description,
        'category': category,
        'lat': lat,
        'lng': lng,
        'address': address,
      });
    } else {
      // Create multipart request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.issuesCreateEndpoint}',
      );
      var request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
      request.fields['address'] = address;

      for (var imagePath in imagePaths) {
        request.files.add(
          await http.MultipartFile.fromPath('images', imagePath),
        );
      }

      final response = await request.send();
      if (response.statusCode >= 300) {
        throw Exception(
          'Failed to create issue. Status: ${response.statusCode}',
        );
      }
    }
  }

  Future<void> updateIssueStatus(String issueId, String status) async {
    await _apiService.post(AppConstants.issuesUpdateStatusEndpoint, {
      'issueId': issueId,
      'status': status,
    });
  }

  Future<void> assignIssue(String issueId, String contractorId) async {
    await _apiService.post(AppConstants.issuesAssignEndpoint, {
      'issueId': issueId,
      'contractorId': contractorId,
    });
  }
}
