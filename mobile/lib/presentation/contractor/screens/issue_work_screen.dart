import 'package:flutter/material.dart';
import '../../../data/models/issue_model.dart';
import '../../../providers/issue_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class IssueWorkScreen extends StatefulWidget {
  final Issue issue;

  const IssueWorkScreen({super.key, required this.issue});

  @override
  State<IssueWorkScreen> createState() => _IssueWorkScreenState();
}

class _IssueWorkScreenState extends State<IssueWorkScreen> {
  File? _completionImage;
  bool _isUpdating = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _completionImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == 'resolved' && _completionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload a completion photo to resolve.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final issueProvider = Provider.of<IssueProvider>(context, listen: false);

    final success = await issueProvider.updateIssueStatus(
      widget.issue.id,
      newStatus,
    );

    if (!mounted) return;

    setState(() {
      _isUpdating = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated successfully!'),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // Go back to dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            issueProvider.errorMessage ?? 'Failed to update status',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'assigned' || status == 'under_contractor_survey') {
      return AppTheme.primaryBlue;
    } else if (status == 'in_progress' || status == 'under_contractor') {
      return AppTheme.warningAmber;
    } else if (status == 'resolved' || status == 'closed') {
      return AppTheme.accentGreen;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.issue.status);

    bool isAssigned =
        widget.issue.status == 'assigned' ||
        widget.issue.status == 'under_contractor_survey';
    bool isInProgress =
        widget.issue.status == 'in_progress' ||
        widget.issue.status == 'under_contractor';

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.glassBoxDecoration(context).copyWith(
                color: theme.cardColor,
                border: Border(left: BorderSide(color: statusColor, width: 6)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.issue.status
                          .split('_')
                          .map((w) => w[0].toUpperCase() + w.substring(1))
                          .join(' '),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.issue.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.issue.gps['address'] ?? 'Unknown location',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.issue.category,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.issue.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),

            if (isAssigned)
              CustomButton(
                text: 'Accept & Start Work',
                onPressed: () => _updateStatus('in_progress'),
                isLoading: _isUpdating,
                icon: Icons.play_arrow_rounded,
                color: theme.primaryColor,
              ),

            if (isInProgress) ...[
              const Text(
                'Upload Completion Proof',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _completionImage != null
                          ? AppTheme.accentGreen
                          : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _completionImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(
                                _completionImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _completionImage = null),
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
                              'Tap to capture photo',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Valid proof is required to resolve.',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Mark as Resolved',
                color: AppTheme.accentGreen,
                icon: Icons.check_circle_rounded,
                onPressed: _completionImage == null
                    ? null
                    : () => _updateStatus('resolved'),
                isLoading: _isUpdating,
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
