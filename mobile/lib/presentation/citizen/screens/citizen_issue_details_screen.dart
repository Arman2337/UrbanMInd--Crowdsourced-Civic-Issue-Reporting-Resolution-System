import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CitizenIssueDetailsScreen extends StatelessWidget {
  final dynamic issue;

  const CitizenIssueDetailsScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image header if available
            if (issue.images != null && issue.images.isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(issue.images[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 180,
                color: theme.primaryColor.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(issue.category),
                    size: 80,
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: theme.textTheme.displayLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(issue.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getStatusColor(issue.status).withOpacity(0.3)),
                        ),
                        child: Text(
                          _formatStatus(issue.status),
                          style: TextStyle(
                            color: _getStatusColor(issue.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Category and Date
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(issue.category),
                        color: theme.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        issue.category,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${issue.createdAt.day}/${issue.createdAt.month}/${issue.createdAt.year}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.displayLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    issue.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Location details
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.displayLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on, color: theme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue.address ?? 'No address provided',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${issue.city ?? 'Unknown City'}${issue.ward != null ? ', Ward ${issue.ward}' : ''}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contractor details if assigned
                  if (issue.contractor != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      'Assigned Contractor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.displayLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassBoxDecoration(context).copyWith(
                        color: theme.primaryColor.withOpacity(0.05),
                        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor.withOpacity(0.2),
                            child: Icon(Icons.engineering_rounded, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.contractor['name'] ?? 'Contractor',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Working on this issue',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return AppTheme.accentGreen;
      case 'in_progress':
      case 'under_contractor':
      case 'under_contractor_survey':
      case 'fund_approval_pending':
        return AppTheme.warningAmber;
      case 'assigned':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.errorRed;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pothole':
        return Icons.directions_car_rounded;
      case 'garbage':
        return Icons.delete_outline_rounded;
      case 'streetlight':
        return Icons.lightbulb_outline_rounded;
      case 'water leakage':
        return Icons.water_drop_outlined;
      case 'drainage':
        return Icons.plumbing_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }

  String _formatStatus(String status) {
    return status
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
