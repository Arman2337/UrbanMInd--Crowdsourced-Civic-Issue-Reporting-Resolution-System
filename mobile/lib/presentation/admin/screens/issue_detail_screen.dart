import 'package:flutter/material.dart';
import '../../../data/models/issue_model.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_constants.dart';

class IssueDetailScreen extends StatelessWidget {
  final Issue issue;
  const IssueDetailScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with image or gradient
          SliverAppBar(
            expandedHeight: issue.images.isNotEmpty ? 280 : 180,
            pinned: true,
            stretch: true,
            backgroundColor: theme.primaryColor,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: issue.images.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          '${AppConstants.baseUrl.replaceAll('/api', '')}${issue.images.first}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white38,
                              size: 60,
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(issue.category),
                          color: Colors.white.withOpacity(0.3),
                          size: 80,
                        ),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusBadge(issue.status),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info cards row
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.calendar_today_rounded,
                        DateFormat('MMM dd, yyyy').format(issue.createdAt),
                        theme,
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        Icons.category_rounded,
                        issue.category,
                        theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.location_city_rounded,
                        issue.city.isNotEmpty ? issue.city : 'Unknown',
                        theme,
                      ),
                      if (issue.gps['address'] != null &&
                          issue.gps['address'].toString().isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoChip(
                            Icons.location_on_rounded,
                            issue.gps['address'],
                            theme,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Description section
                  _buildSectionHeader(
                    'Description',
                    Icons.description_rounded,
                    theme,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      issue.description.isNotEmpty
                          ? issue.description
                          : 'No description provided.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Images section
                  if (issue.images.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      'Photos (${issue.images.length})',
                      Icons.photo_library_rounded,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: issue.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              '${AppConstants.baseUrl.replaceAll('/api', '')}${issue.images[index]}',
                              width: 240,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 240,
                                height: 180,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade400,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Location section
                  const SizedBox(height: 28),
                  _buildSectionHeader('Location', Icons.map_rounded, theme),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.gps_fixed_rounded,
                              size: 18,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lat: ${issue.gps['lat']}, Lng: ${issue.gps['lng']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (issue.gps['address'] != null &&
                            issue.gps['address'].toString().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.place_rounded,
                                size: 18,
                                color: AppTheme.errorRed,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  issue.gps['address'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.primaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return AppTheme.accentGreen;
      case 'in_progress':
      case 'under_contractor':
      case 'fund_approval_pending':
        return AppTheme.warningAmber;
      case 'assigned':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.errorRed;
    }
  }

  String _formatStatus(String status) {
    return status
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
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
}
