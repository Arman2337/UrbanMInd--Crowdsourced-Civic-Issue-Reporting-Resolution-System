import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../providers/issue_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/theme/app_theme.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCategory = 'Pothole';
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Pothole', 'icon': Icons.directions_car_rounded},
    {'name': 'Garbage', 'icon': Icons.delete_outline_rounded},
    {'name': 'Streetlight', 'icon': Icons.lightbulb_outline_rounded},
    {'name': 'Water Leakage', 'icon': Icons.water_drop_outlined},
    {'name': 'Drainage', 'icon': Icons.plumbing_rounded},
    {'name': 'Other', 'icon': Icons.report_problem_rounded},
  ];

  File? _imageFile;
  Position? _currentPosition;
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Photo Evidence',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppTheme.accentGreen,
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position? knownPosition = await Geolocator.getLastKnownPosition();
      Position position = knownPosition ?? await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      // Reverse geocode to get a proper address
      String address = '${position.latitude}, ${position.longitude}';
      try {
        final geoUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=16&addressdetails=1',
        );
        final geoResponse = await http.get(
          geoUrl,
          headers: {'User-Agent': 'UrbanMind-Civic-App/1.0'},
        );
        if (geoResponse.statusCode == 200) {
          final geoData = json.decode(geoResponse.body);
          if (geoData['display_name'] != null) {
            address = geoData['display_name'];
          }
        }
      } catch (_) {
        debugPrint('Reverse geocoding failed, using raw coordinates');
      }

      setState(() {
        _currentPosition = position;
        _addressController.text = address;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  void _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fetch current location first'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    List<String> imagePaths = [];
    if (_imageFile != null) {
      imagePaths.add(_imageFile!.path);
    }

    final success = await issueProvider.createIssue(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
      address: _addressController.text.trim(),
      imagePaths: imagePaths,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue reported successfully!'),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(issueProvider.errorMessage ?? 'Failed to report issue'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue'), elevation: 0),
      body: Consumer<IssueProvider>(
        builder: (context, issueProvider, _) {
          return LoadingOverlay(
            isLoading: issueProvider.isLoading,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                children: [
                  _buildSectionTitle('Issue Category'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['name'];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : theme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat['name'] as String;
                            });
                          }
                        },
                        selectedColor: theme.primaryColor,
                        backgroundColor: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        elevation: isSelected ? 4 : 0,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Issue Details'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Title',
                    hintText: 'E.g. Large pothole on Main St.',
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Description',
                    hintText: 'Describe the issue in detail...',
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          labelText: '',
                          hintText: 'Address or coordinates',
                          controller: _addressController,
                          prefixIcon: Icons.location_on_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 56, // matches CustomTextField height
                        decoration: BoxDecoration(
                          color: _currentPosition != null
                              ? AppTheme.accentGreen
                              : theme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_currentPosition != null
                                          ? AppTheme.accentGreen
                                          : theme.primaryColor)
                                      .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _isFetchingLocation
                              ? null
                              : _fetchLocation,
                          icon: _isFetchingLocation
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _currentPosition != null
                                      ? Icons.my_location_rounded
                                      : Icons.location_searching_rounded,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Photo Evidence'),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _imageFile != null
                              ? theme.primaryColor
                              : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          if (_imageFile == null)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                      child: _imageFile != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageFile = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 32,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tap to upload a photo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Clear images help contractors resolve issues faster',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomButton(
                    text: 'Submit Issue',
                    onPressed: _submitIssue,
                    icon: Icons.send_rounded,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}
