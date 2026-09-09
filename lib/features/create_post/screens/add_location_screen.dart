import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/create_post/domain/entities/post_location.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key, this.initial});

  final PostLocation? initial;

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Geocoding _geocoding = Geocoding();
  PostLocation? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _loading = false;
          _error = 'Location services are turned off.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _loading = false;
          _error = 'Location permission was denied.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _error =
              'Location permission is permanently denied. Enable it in Settings.';
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String label = 'Current Location';
      String address = '';
      try {
        final List<Placemark> places = await _geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (places.isNotEmpty) {
          final Placemark place = places.first;
          final List<String> line = <String>[
            if ((place.name ?? '').trim().isNotEmpty) place.name!.trim(),
            if ((place.street ?? '').trim().isNotEmpty &&
                place.street != place.name)
              place.street!.trim(),
            if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
            if ((place.administrativeArea ?? '').trim().isNotEmpty)
              place.administrativeArea!.trim(),
            if ((place.postalCode ?? '').trim().isNotEmpty)
              place.postalCode!.trim(),
          ];
          address = line.join(', ');
          label = (place.locality ?? place.subLocality ?? place.name ?? label)
              .toString()
              .trim();
          if (label.isEmpty) label = 'Current Location';
        }
      } catch (_) {
        // Keep coordinates fallback below.
      }

      if (!mounted) return;
      setState(() {
        _selected = PostLocation(
          label: label,
          address: address.isNotEmpty
              ? address
              : '${position.latitude.toStringAsFixed(5)}, '
                    '${position.longitude.toStringAsFixed(5)}',
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not get your current location.';
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    final String q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<Location> results = await _geocoding.locationFromAddress(q);
      if (results.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No location found for that search.';
        });
        return;
      }

      final Location first = results.first;
      String label = q;
      String address = q;
      try {
        final List<Placemark> places = await _geocoding.placemarkFromCoordinates(
          first.latitude,
          first.longitude,
        );
        if (places.isNotEmpty) {
          final Placemark place = places.first;
          label = (place.name ?? place.locality ?? q).toString().trim();
          address = <String>[
            if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
            if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
            if ((place.administrativeArea ?? '').trim().isNotEmpty)
              place.administrativeArea!.trim(),
            if ((place.postalCode ?? '').trim().isNotEmpty)
              place.postalCode!.trim(),
          ].join(', ');
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _selected = PostLocation(
          label: label.isEmpty ? q : label,
          address: address.isEmpty ? q : address,
          latitude: first.latitude,
          longitude: first.longitude,
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not search that location.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close, size: ScreenUtils.sp(22)),
        ),
        centerTitle: true,
        title: Text(
          'ADD LOCATION',
          style: AppTypography.semiBold(
            fontSize: 16,
            color: AppColors.primaryButtonBg,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _selected == null
                ? null
                : () => context.pop(_selected),
            child: Text(
              'Done',
              style: AppTypography.semiBold(
                fontSize: 14,
                color: _selected == null
                    ? AppColors.mutedGrey
                    : AppColors.primaryButtonBg,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(8),
          ScreenUtils.w(16),
          ScreenUtils.h(24),
        ),
        children: <Widget>[
          TextField(
            controller: _searchController,
            style: AppTypography.medium(fontSize: 14),
            cursorColor: AppColors.primaryButtonBg,
            textInputAction: TextInputAction.search,
            onSubmitted: _searchLocation,
            decoration: InputDecoration(
              hintText: 'Search location.',
              hintStyle: AppTypography.medium(
                fontSize: 14,
                color: AppColors.mutedGrey,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(20),
              ),
              filled: true,
              fillColor: AppColors.cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                borderSide: const BorderSide(color: AppColors.primaryButtonBg),
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppColors.primaryButtonBg,
                ),
              ),
            )
          else if (_error != null) ...<Widget>[
            Text(
              _error!,
              style: AppTypography.medium(
                fontSize: 13,
                color: AppColors.mutedGrey,
              ),
            ),
            SizedBox(height: ScreenUtils.h(12)),
            TextButton(
              onPressed: _loadCurrentLocation,
              child: Text(
                'Try again / use current location',
                style: AppTypography.semiBold(
                  fontSize: 13,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ),
          ] else if (_selected != null)
            Container(
              padding: EdgeInsets.all(ScreenUtils.w(14)),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                border: Border.all(
                  color: AppColors.primaryButtonBg.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(22),
                  ),
                  SizedBox(width: ScreenUtils.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _selected!.label,
                          style: AppTypography.semiBold(fontSize: 14),
                        ),
                        if (_selected!.displaySubtitle.isNotEmpty) ...<Widget>[
                          SizedBox(height: ScreenUtils.h(4)),
                          Text(
                            _selected!.displaySubtitle,
                            style: AppTypography.medium(
                              fontSize: 12,
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selected = null),
                    child: Icon(
                      Icons.close,
                      color: AppColors.mutedGrey,
                      size: ScreenUtils.sp(18),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: ScreenUtils.h(20)),
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () {
                    AppSnackBar.showInfo(
                      context,
                      title: 'Current Location',
                      message: 'Fetching your current location…',
                    );
                    _loadCurrentLocation();
                  },
            icon: const Icon(Icons.my_location),
            label: const Text('Use current location'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryButtonBg,
              side: const BorderSide(color: AppColors.primaryButtonBg),
              minimumSize: Size(double.infinity, ScreenUtils.h(46)),
            ),
          ),
        ],
      ),
    );
  }
}
