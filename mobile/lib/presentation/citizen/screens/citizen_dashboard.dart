import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/issue_provider.dart';
import 'report_issue_screen.dart';
import 'my_issues_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'citizen_issue_details_screen.dart';
import '../../auth/screens/role_selection_screen.dart';
import '../../../core/theme/app_theme.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const MapScreen(),
    const MyIssuesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ReportIssueScreen(),
                    transitionsBuilder: (_, a, __, c) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(a),
                      child: c,
                    ),
                  ),
                ).then((_) {
                  // Refresh data when returning from report screen
                  Provider.of<IssueProvider>(
                    context,
                    listen: false,
                  ).fetchMyIssues();
                  Provider.of<IssueProvider>(
                    context,
                    listen: false,
                  ).fetchAllIssues();
                });
              },
              backgroundColor: theme.primaryColor,
              elevation: 4,
              icon: const Icon(
                Icons.add_location_alt_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Report Issue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.cardColor,
            selectedItemColor: theme.primaryColor,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map_rounded),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                activeIcon: Icon(Icons.list_alt_rounded),
                label: 'My Issues',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();

    // Fetch real data from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      issueProvider.fetchMyIssues();
      issueProvider.fetchAllIssues();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    await issueProvider.fetchMyIssues();
    await issueProvider.fetchAllIssues();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final issueProvider = Provider.of<IssueProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);

    // Calculate real stats from fetched data
    final myIssues = issueProvider.myIssues;
    final totalReports = myIssues.length;
    final resolvedCount = myIssues
        .where((i) => i.status == 'resolved' || i.status == 'closed')
        .length;
    final pendingCount = myIssues
        .where((i) => i.status == 'reported' || i.status == 'pending')
        .length;
    final inProgressCount = myIssues
        .where(
          (i) =>
              i.status == 'assigned' ||
              i.status == 'in_progress' ||
              i.status == 'under_contractor' ||
              i.status == 'under_contractor_survey' ||
              i.status == 'fund_approval_pending',
        )
        .length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: theme.primaryColor),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.1),
                      theme.scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?['name'] ?? 'Citizen'} 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: theme.textTheme.displayLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let\'s build a better city together.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Action Card
                    _buildAnimatedCard(
                      index: 1,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Spot an issue?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Report potholes, garbage, and more.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Text(
                      'Your Impact',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: theme.textTheme.displayLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Grid — Live Data
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnimatedStatCard(
                            1,
                            'Total Reports',
                            '$totalReports',
                            AppTheme.primaryBlue,
                            Icons.assignment_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnimatedStatCard(
                            2,
                            'Resolved',
                            '$resolvedCount',
                            AppTheme.accentGreen,
                            Icons.check_circle_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnimatedStatCard(
                            3,
                            'Pending',
                            '$pendingCount',
                            AppTheme.warningAmber,
                            Icons.pending_actions_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnimatedStatCard(
                            4,
                            'In Progress',
                            '$inProgressCount',
                            Colors.deepPurple,
                            Icons.engineering_rounded,
                          ),
                        ),
                      ],
                    ),

                    // Recent Issues Section
                    if (myIssues.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      Text(
                        'Recent Reports',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.textTheme.displayLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...myIssues
                          .take(3)
                          .map(
                            (issue) => _buildAnimatedCard(
                              index: 5,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CitizenIssueDetailsScreen(issue: issue),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      issue.status,
                                    ).withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          issue.status,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(issue.category),
                                        color: _getStatusColor(issue.status),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            issue.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            issue.category,
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          issue.status,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _formatStatus(issue.status),
                                        style: TextStyle(
                                          color: _getStatusColor(issue.status),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
      ),
    );
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }

  Widget _buildAnimatedStatCard(
    int index,
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return _buildAnimatedCard(
      index: index + 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassBoxDecoration(context).copyWith(
          color: Theme.of(context).cardColor,
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 16),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
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
