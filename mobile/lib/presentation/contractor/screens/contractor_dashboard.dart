import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/issue_provider.dart';
import '../../widgets/issue_card.dart';
import '../../auth/screens/role_selection_screen.dart';
import 'issue_work_screen.dart';
import '../../../core/theme/app_theme.dart';

class ContractorDashboard extends StatefulWidget {
  const ContractorDashboard({super.key});

  @override
  State<ContractorDashboard> createState() => _ContractorDashboardState();
}

class _ContractorDashboardState extends State<ContractorDashboard>
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
        title: const Text('Workspace'),
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
          final contractorId = user?['_id'];
          final assignedIssues = issueProvider.issues
              .where((issue) => 
                issue.status != 'closed' && 
                issue.contractorId == contractorId
              )
              .toList();
          final pendingCount = assignedIssues
              .where((i) => i.status == 'assigned')
              .length;
          final inProgressCount = assignedIssues
              .where((i) => i.status == 'in_progress')
              .length;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: theme.primaryColor,
            child: Column(
              children: [
                _buildStatsHeader(context, user, pendingCount, inProgressCount),
                Expanded(
                  child: assignedIssues.isEmpty && !issueProvider.isLoading
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(top: 16, bottom: 32),
                          itemCount: assignedIssues.length,
                          itemBuilder: (context, index) {
                            final issue = assignedIssues[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 100).clamp(0, 500),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: IssueCard(
                                issue: issue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          IssueWorkScreen(issue: issue),
                                      transitionsBuilder: (_, a, __, c) =>
                                          SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(a),
                                            child: c,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    Map<String, dynamic>? user,
    int pendingCount,
    int inProgressCount,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
      decoration: BoxDecoration(
        color: theme.primaryColor,
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
            child: const Text(
              'Overview',
              style: TextStyle(
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
              user?['name'] ?? 'Contractor',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedStatBox(
                  context,
                  index: 1,
                  label: 'Assigned',
                  value: pendingCount.toString(),
                  icon: Icons.assignment_rounded,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnimatedStatBox(
                  context,
                  index: 2,
                  label: 'In Progress',
                  value: inProgressCount.toString(),
                  icon: Icons.engineering_rounded,
                  color: AppTheme.warningAmber.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatBox(
    BuildContext context, {
    required int index,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.05),
          ),
          child: Icon(
            Icons.task_alt_rounded,
            size: 100,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'All Caught Up!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'You have no assigned tasks right now. Great job!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
