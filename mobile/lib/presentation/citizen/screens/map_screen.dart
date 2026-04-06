import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../providers/issue_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final String? cityFilter;
  const MapScreen({super.key, this.cityFilter});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(19.0760, 72.8777); // Default Mumbai
  bool _isLoadingLocation = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndIssues();
  }

  Future<void> _fetchLocationAndIssues() async {
    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    await issueProvider.fetchAllIssues();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationError =
                'Location services are disabled. Please enable them.';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _locationError =
                  'Location permission denied. Showing default location.';
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationError =
                'Location permissions permanently denied. Please enable in settings.';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      Position? knownPosition = await Geolocator.getLastKnownPosition();
      Position position = knownPosition ?? await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );
      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        try {
          _mapController.move(_center, 14.0);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
      if (mounted) {
        setState(() {
          _locationError = 'Could not fetch location.';
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('City Map'),
        backgroundColor: isDark
            ? Colors.black.withOpacity(0.5)
            : Colors.white.withOpacity(0.85),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : AppTheme.primaryBlue,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.my_location_rounded, color: Colors.white),
              onPressed: () {
                _mapController.move(_center, 14.0);
              },
            ),
          ),
        ],
      ),
      body: Consumer<IssueProvider>(
        builder: (context, issueProvider, _) {
          // Backend already filters by admin's city, no need to filter again
          final displayIssues = issueProvider.issues;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    // Always use bright, colorful Voyager tiles for both themes
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.urbanmind',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: displayIssues.map((issue) {
                      Color markerColor = _getStatusColor(issue.status);
                      IconData markerIcon = _getCategoryIcon(issue.category);

                      return Marker(
                        point: LatLng(
                          (issue.gps['lat'] is num)
                              ? (issue.gps['lat'] as num).toDouble()
                              : 0.0,
                          (issue.gps['lng'] is num)
                              ? (issue.gps['lng'] as num).toDouble()
                              : 0.0,
                        ),
                        width: 60,
                        height: 70,
                        child: GestureDetector(
                          onTap: () =>
                              _showIssueDetails(context, issue, markerColor),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: markerColor.withOpacity(0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  markerIcon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              // Pointer triangle
                              CustomPaint(
                                size: const Size(14, 8),
                                painter: _TrianglePainter(markerColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Loading indicator
              if (_isLoadingLocation || issueProvider.isLoading)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Loading map data...',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Issue count badge
              if (!issueProvider.isLoading && !_isLoadingLocation)
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pin_drop_rounded,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${displayIssues.length} issues${widget.cityFilter != null ? ' in ${widget.cityFilter}' : ' nearby'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Legend
              if (!issueProvider.isLoading && !_isLoadingLocation)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _legendItem(AppTheme.errorRed, 'Reported'),
                        const SizedBox(height: 4),
                        _legendItem(AppTheme.primaryBlue, 'Assigned'),
                        const SizedBox(height: 4),
                        _legendItem(AppTheme.warningAmber, 'In Progress'),
                        const SizedBox(height: 4),
                        _legendItem(AppTheme.accentGreen, 'Resolved'),
                      ],
                    ),
                  ),
                ),

              // Location error banner
              if (_locationError != null)
                Positioned(
                  bottom: 60,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningAmber.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _locationError!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _locationError = null),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black54,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  void _showIssueDetails(
    BuildContext context,
    dynamic issue,
    Color markerColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: markerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCategoryIcon(issue.category),
                      color: markerColor,
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
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          issue.category,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                issue.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: markerColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: markerColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      issue.status
                          .split('_')
                          .map((w) => w[0].toUpperCase() + w.substring(1))
                          .join(' '),
                      style: TextStyle(
                        color: markerColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${issue.createdAt.day}/${issue.createdAt.month}/${issue.createdAt.year}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
}

/// Custom painter for marker pointer triangle
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
