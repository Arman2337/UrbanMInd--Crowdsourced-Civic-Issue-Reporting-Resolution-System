import 'package:flutter/material.dart';
import '../../data/repositories/issue_repository.dart';
import '../../data/models/issue_model.dart';
import '../../data/network/api_service.dart';
import '../../core/utils/app_constants.dart';

class IssueProvider extends ChangeNotifier {
  final IssueRepository _issueRepository = IssueRepository();
  bool _isLoading = false;
  String? _errorMessage;

  List<Issue> _issues = [];
  List<Issue> _myIssues = [];
  List<Map<String, dynamic>> _contractors = [];
  bool _isLoadingContractors = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Issue> get issues => _issues;
  List<Issue> get myIssues => _myIssues;
  List<Map<String, dynamic>> get contractors => _contractors;
  bool get isLoadingContractors => _isLoadingContractors;

  Future<void> fetchMyIssues() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myIssues = await _issueRepository.getMyIssues();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllIssues() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _issues = await _issueRepository.getAllIssues();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createIssue({
    required String title,
    required String description,
    required String category,
    required double lat,
    required double lng,
    required String address,
    required List<String> imagePaths,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _issueRepository.createIssue(
        title: title,
        description: description,
        category: category,
        lat: lat,
        lng: lng,
        address: address,
        imagePaths: imagePaths,
      );

      _isLoading = false;
      notifyListeners();

      // Refresh my issues after creating
      fetchMyIssues();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateIssueStatus(String issueId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _issueRepository.updateIssueStatus(issueId, status);
      _isLoading = false;
      notifyListeners();

      // Refresh lists
      fetchAllIssues();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchContractors() async {
    _isLoadingContractors = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      debugPrint(
        '[CONTRACTORS] Fetching from: ${AppConstants.adminContractorsEndpoint}',
      );
      final response = await apiService.get(
        AppConstants.adminContractorsEndpoint,
      );
      debugPrint('[CONTRACTORS] Response type: ${response.runtimeType}');
      debugPrint('[CONTRACTORS] Response: $response');
      if (response is List) {
        _contractors = List<Map<String, dynamic>>.from(response);
        debugPrint('[CONTRACTORS] Loaded ${_contractors.length} contractors');
      } else {
        _contractors = [];
        debugPrint('[CONTRACTORS] Response was not a list, got: $response');
      }
      _isLoadingContractors = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[CONTRACTORS] Error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoadingContractors = false;
      _contractors = [];
      notifyListeners();
    }
  }

  Future<bool> assignContractor(String issueId, String contractorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _issueRepository.assignIssue(issueId, contractorId);
      _isLoading = false;
      notifyListeners();

      // Refresh issues list
      fetchAllIssues();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
