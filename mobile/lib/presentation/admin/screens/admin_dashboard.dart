import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/issue_provider.dart';
import '../../auth/screens/role_selection_screen.dart';
import '../../citizen/screens/map_screen.dart';
import 'issue_management_screen.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  List<Widget>? _screens;

  List<Widget> _buildScreens(String? adminCity) {
    _screens ??= [
      const _AdminDashboardHome(),
      MapScreen(cityFilter: adminCity),
      const IssueManagementScreen(),
    ];
    return _screens!;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminCity = authProvider.user?['city'] as String?;
    final theme = Theme.of(context);
    final screens = _buildScreens(adminCity);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
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
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
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
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map_rounded),
                label: 'City Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_outlined),
                activeIcon: Icon(Icons.admin_panel_settings_rounded),
                label: 'Manage',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminDashboardHome extends StatefulWidget {
  const _AdminDashboardHome();

  @override
  State<_AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends State<_AdminDashboardHome>
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IssueProvider>(context, listen: false).fetchAllIssues();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Provider.of<IssueProvider>(context, listen: false).fetchAllIssues();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Admin Portal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
          ),
        ],
      ),
      body: Consumer<IssueProvider>(
        builder: (context, issueProvider, _) {
          final issues = issueProvider.issues
              .where((i) => i.city.toLowerCase() == (user?['city'] as String? ?? '').toLowerCase())
              .toList();
          final pending = issues
              .where((i) => i.status == 'reported' || i.status == 'assigned')
              .length;
          final inProgress = issues
              .where(
                (i) =>
                    i.status == 'in_progress' || i.status == 'under_contractor',
              )
              .length;
          final resolved = issues
              .where((i) => i.status == 'resolved' || i.status == 'closed')
              .length;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: theme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _animationController,
                          child: Text(
                            '${user?['city'] ?? "City"} Operations',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FadeTransition(
                          opacity: _animationController,
                          child: Text(
                            'Welcome, ${user?['name'] ?? 'Admin'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildAnimatedCard(
                          index: 1,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Issues',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      issues.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_city_rounded,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'City Metrics',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: theme.textTheme.displayLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridCard(
                                context,
                                2,
                                'Pending',
                                pending.toString(),
                                AppTheme.errorRed,
                                Icons.warning_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGridCard(
                                context,
                                3,
                                'In Progress',
                                inProgress.toString(),
                                AppTheme.warningAmber,
                                Icons.construction_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridCard(
                                context,
                                4,
                                'Resolved',
                                resolved.toString(),
                                AppTheme.accentGreen,
                                Icons.check_circle_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGridCard(
                                context,
                                5,
                                'Contractors',
                                'Active',
                                theme.primaryColor,
                                Icons.engineering_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.15, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.15, 1.0, curve: Curves.easeOut),
      ),
    );
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    int index,
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return _buildAnimatedCard(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassBoxDecoration(context).copyWith(
          color: Theme.of(context).cardColor,
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
