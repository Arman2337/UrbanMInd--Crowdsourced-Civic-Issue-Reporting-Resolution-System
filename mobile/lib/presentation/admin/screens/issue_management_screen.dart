import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/issue_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/issue_card.dart';
import '../../../core/theme/app_theme.dart';
import 'issue_detail_screen.dart';

class IssueManagementScreen extends StatefulWidget {
  const IssueManagementScreen({super.key});

  @override
  State<IssueManagementScreen> createState() => _IssueManagementScreenState();
}

class _IssueManagementScreenState extends State<IssueManagementScreen> {
  String _filterStatus = 'All';
  final List<String> _statuses = [
    'All',
    'Reported',
    'Assigned',
    'In Progress',
    'Resolved',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Issues'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: theme.textTheme.displayLarge?.color,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: _statuses.map((status) {
                  final isSelected = _filterStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: FilterChip(
                        label: Text(
                          status,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.primaryColor,
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = status;
                          });
                        },
                        backgroundColor: theme.cardColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        elevation: isSelected ? 4 : 0,
                        shadowColor: theme.primaryColor.withOpacity(0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: Consumer<IssueProvider>(
              builder: (context, issueProvider, _) {
                final issues = issueProvider.issues.where((issue) {
                  final adminCity = Provider.of<AuthProvider>(context, listen: false).user?['city'] as String?;
                  if (issue.city.toLowerCase() != (adminCity ?? '').toLowerCase()) {
                    return false;
                  }
                  if (_filterStatus == 'All') return true;
                  final statusFormat = issue.status
                      .replaceAll('_', ' ')
                      .toLowerCase();
                  return statusFormat == _filterStatus.toLowerCase();
                }).toList();

                if (issues.isEmpty && !issueProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 80,
                            color: theme.primaryColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Issues Found',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: theme.textTheme.displayLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'There are no $_filterStatus issues at this time.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(
                        milliseconds: 300 + (index * 50).clamp(0, 300),
                      ),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: IssueCard(
                        issue: issue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IssueDetailScreen(issue: issue),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showAdminOptionsDialog(context, issue);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminOptionsDialog(BuildContext context, dynamic issue) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassBoxDecoration(context).copyWith(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                issue.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              if (issue.status == 'reported' || issue.status == 'assigned') ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      color: theme.primaryColor,
                    ),
                  ),
                  title: const Text(
                    'Assign Contractor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // Use addPostFrameCallback to avoid setState during build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showContractorListDialog(context, issue);
                    });
                  },
                ),
                Divider(color: Colors.grey.shade200),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.errorRed,
                  ),
                ),
                title: const Text(
                  'Delete Issue',
                  style: TextStyle(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showContractorListDialog(BuildContext context, dynamic issue) {
    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    issueProvider.fetchContractors();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return Container(
          margin: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.engineering_rounded,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Contractor',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'For: ${issue.title}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200, height: 1),
                  ],
                ),
              ),

              // Contractor List
              Flexible(
                child: Consumer<IssueProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingContractors) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final adminCity = Provider.of<AuthProvider>(context, listen: false).user?['city'] as String?;
                    final cityContractors = provider.contractors.where(
                      (c) => (c['city'] ?? '').toLowerCase() == (adminCity ?? '').toLowerCase()
                    ).toList();

                    if (cityContractors.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_off_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                provider.errorMessage ??
                                    'No contractors available for your city',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Check backend logs for [DEBUG] details',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: cityContractors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final contractor = cityContractors[index];
                        final name =
                            contractor['companyName'] ??
                            contractor['name'] ??
                            'Unknown';
                        final email = contractor['email'] ?? '';
                        final rating = (contractor['rating'] ?? 0).toDouble();
                        final completed = contractor['completedTasks'] ?? 0;
                        final efficiency = contractor['efficiency'] ?? 0;
                        final isActive = contractor['isActive'] == true;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final success = await issueProvider
                                  .assignContractor(
                                    issue.id,
                                    contractor['_id'],
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Assigned to $name successfully!'
                                          : 'Failed to assign contractor.',
                                    ),
                                    backgroundColor: success
                                        ? AppTheme.accentGreen
                                        : AppTheme.errorRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive
                                      ? AppTheme.accentGreen.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isActive)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentGreen
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Active',
                                                  style: TextStyle(
                                                    color: AppTheme.accentGreen,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: AppTheme.warningAmber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 14,
                                              color: AppTheme.accentGreen,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$completed done',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.speed_rounded,
                                              size: 14,
                                              color: theme.primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$efficiency%',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
