import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock notifications data for the "fully working" frontend UI
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Issue Resolved',
        'message': 'Your report regarding "Potholes on Main St." has been marked as resolved.',
        'time': 'Just now',
        'icon': Icons.check_circle_rounded,
        'color': AppTheme.accentGreen,
        'isRead': false,
      },
      {
        'title': 'Contractor Assigned',
        'message': 'A contractor has been assigned to your reported issue "Streetlight Outage".',
        'time': '2 hours ago',
        'icon': Icons.engineering_rounded,
        'color': AppTheme.warningAmber,
        'isRead': false,
      },
      {
        'title': 'Funds Approved',
        'message': 'City Admin has approved ₹50,000 for "Broken Walkway" repairs.',
        'time': '1 day ago',
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppTheme.primaryBlue,
        'isRead': true,
      },
      {
        'title': 'Welcome to UrbanMind!',
        'message': 'Thank you for joining our community to make the city better.',
        'time': '3 days ago',
        'icon': Icons.waving_hand_rounded,
        'color': Colors.deepPurple,
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: theme.textTheme.displayLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppTheme.primaryBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications marked as read.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.accentGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isRead = notif['isRead'] as bool;
          
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 500)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Action when clicked
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRead 
                        ? theme.cardColor 
                        : theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRead 
                          ? Colors.grey.withOpacity(0.1) 
                          : theme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (notif['color'] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notif['icon'] as IconData,
                          color: notif['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif['title'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
                                      color: theme.textTheme.displayLarge?.color,
                                    ),
                                  ),
                                ),
                                Text(
                                  notif['time'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notif['message'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isRead ? Colors.grey.shade600 : Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
