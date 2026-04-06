import 'package:flutter/material.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFadeInText(
                index: 0,
                child: Icon(
                  Icons.people_alt_rounded,
                  size: 70,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildFadeInText(
                index: 1,
                child: Text(
                  'Welcome to UrbanMind',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFadeInText(
                index: 2,
                child: Text(
                  'Please select your role to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _buildAnimatedRoleCard(
                index: 3,
                title: 'Citizen',
                description: 'Report issues and track progress',
                icon: Icons.person_rounded,
                role: 'citizen',
                color: theme.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildAnimatedRoleCard(
                index: 4,
                title: 'Contractor',
                description: 'View assigned tasks and update status',
                icon: Icons.engineering_rounded,
                role: 'contractor',
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              _buildAnimatedRoleCard(
                index: 5,
                title: 'City Admin',
                description: 'Manage city issues and contractors',
                icon: Icons.admin_panel_settings_rounded,
                role: 'admin',
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFadeInText({required int index, required Widget child}) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(opacity: animation, child: child);
  }

  Widget _buildAnimatedRoleCard({
    required int index,
    required String title,
    required String description,
    required IconData icon,
    required String role,
    required Color color,
  }) {
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
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
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.1), width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => LoginScreen(role: role),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              splashColor: color.withOpacity(0.1),
              highlightColor: color.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
