import 'package:flutter/material.dart';
import '../../data/models/issue_model.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const IssueCard({
    super.key,
    required this.issue,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: AppTheme.glassBoxDecoration(
        context,
      ).copyWith(color: Theme.of(context).cardColor),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.15),
                            Theme.of(context).primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getCategoryIcon(issue.category),
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            issue.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  issue.gps['address'] ?? 'Unknown location',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.withOpacity(0.1), height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM dd, yyyy').format(issue.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(issue.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(issue.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _formatStatus(issue.status),
                        style: TextStyle(
                          color: _getStatusColor(issue.status),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        return AppTheme.errorRed; // reported
    }
  }

  String _formatStatus(String status) {
    return status
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
