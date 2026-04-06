import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/issue_provider.dart';
import '../../widgets/issue_card.dart';
import '../../widgets/loading_overlay.dart';
import 'citizen_issue_details_screen.dart';

class MyIssuesScreen extends StatefulWidget {
  const MyIssuesScreen({super.key});

  @override
  State<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IssueProvider>(context, listen: false).fetchMyIssues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Issues'),
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
      body: Consumer<IssueProvider>(
        builder: (context, issueProvider, _) {
          return LoadingOverlay(
            isLoading:
                issueProvider.isLoading && issueProvider.myIssues.isEmpty,
            child: RefreshIndicator(
              onRefresh: () => issueProvider.fetchMyIssues(),
              color: theme.primaryColor,
              child: issueProvider.myIssues.isEmpty && !issueProvider.isLoading
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      itemCount: issueProvider.myIssues.length,
                      itemBuilder: (context, index) {
                        final issue = issueProvider.myIssues[index];
                        // Add staggered animation entrance dynamically based on index in list view
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
                                MaterialPageRoute(
                                  builder: (context) => CitizenIssueDetailsScreen(issue: issue),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor.withOpacity(0.05),
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 100,
                  color: theme.primaryColor.withOpacity(0.5),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'No Issues Reported',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: theme.textTheme.displayLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'You haven\'t reported any civic issues yet. Issues you report will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
