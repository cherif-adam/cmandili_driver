import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

import '../../../../core/theme/app_colors.dart';

/// Small, static driver -> pickup map shown inside the offer dialog.
///
/// Deliberately NOT built on [AppMap]. AppMap is the live-tracking map: it
/// drives an AnimationController that setStates every tick to tween the driver
/// marker between GPS fixes, and rasterizes its marker icons after first frame.
/// All of that is dead weight for a two-point still image, and it would couple
/// this dialog to a widget that is actively being changed for the tracking
/// screen — a regression there would land straight in the offer flow, which is
/// the one screen that must not break.
///
/// Lite mode renders the map as a static bitmap instead of a live platform
/// view. That matters here specifically because this dialog can mount moments
/// after a cold start / full-screen-intent wake, while a countdown is already
/// running against the driver. Note this is an ANDROID-ONLY optimisation:
/// google_maps_flutter_ios ignores `liteModeEnabled` entirely, so on iOS this
/// is a normal (if fully gesture-disabled) map. It does not throw there — it
/// just doesn't get the cheaper render path.
///
/// The line is a straight driver->pickup segment, not a routed path. It matches
/// what the distance/ETA pills already claim to be (haversine over an assumed
/// average speed), and avoids a Directions call on every offer — the dispatch
/// waterfall re-offers the same order down the driver list, so per-offer
/// routing would cost N calls per order, worst when dispatch is going badly.
///
/// Never load-bearing: the pills above it carry the decision-critical numbers,
/// so the dialog stays fully usable whatever this does. Be precise about what
/// that buys though — the placeholder below only covers unusable COORDINATES.
/// The Maps SDK exposes no tile-load callback, so if tiles fail (offline, cold
/// SDK, slow network) this renders as an empty map frame rather than a
/// placeholder. That is accepted: it costs the driver nothing, because the
/// distance and ETA they actually decide on are already on screen above.
class OfferRoutePreview extends StatelessWidget {
  final double driverLat;
  final double driverLng;
  final double pickupLat;
  final double pickupLng;

  /// Shown under the pickup pin — restaurant/shop name, or a courier label.
  final String? pickupLabel;

  const OfferRoutePreview({
    super.key,
    required this.driverLat,
    required this.driverLng,
    required this.pickupLat,
    required this.pickupLng,
    this.pickupLabel,
  });

  /// Garbage coordinates would send the camera somewhere absurd or crash the
  /// bounds maths (NaN/Infinity propagate straight into LatLngBounds). Venue
  /// rows in this project have carried placeholder and out-of-range values
  /// before, so this is a real input, not a theoretical one.
  bool get _coordsUsable {
    for (final v in [driverLat, pickupLat]) {
      if (!v.isFinite || v < -90 || v > 90) return false;
    }
    for (final v in [driverLng, pickupLng]) {
      if (!v.isFinite || v < -180 || v > 180) return false;
    }
    return true;
  }

  /// Camera bounds that fit both points with a little breathing room.
  gm.LatLngBounds get _bounds {
    final swLat = math.min(driverLat, pickupLat);
    final swLng = math.min(driverLng, pickupLng);
    final neLat = math.max(driverLat, pickupLat);
    final neLng = math.max(driverLng, pickupLng);
    // Pad so the markers aren't clipped against the edge. When the two points
    // are nearly identical the raw box collapses and the camera zooms to max,
    // so floor the padding at ~150m.
    final padLat = math.max((neLat - swLat) * 0.35, 0.0015);
    final padLng = math.max((neLng - swLng) * 0.35, 0.0015);
    return gm.LatLngBounds(
      southwest: gm.LatLng(swLat - padLat, swLng - padLng),
      northeast: gm.LatLng(neLat + padLat, neLng + padLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_coordsUsable) return _placeholder('Aperçu de la carte indisponible');

    final driver = gm.LatLng(driverLat, driverLng);
    final pickup = gm.LatLng(pickupLat, pickupLng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          children: [
            gm.GoogleMap(
              // Static bitmap on Android; the whole point of using it here.
              liteModeEnabled: true,
              initialCameraPosition: gm.CameraPosition(target: pickup, zoom: 13),
              // Lite mode ignores most gestures anyway; turning them off makes
              // the intent explicit and stops the map stealing drags from the
              // dialog's scroll view.
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              markers: {
                gm.Marker(
                  markerId: const gm.MarkerId('driver'),
                  position: driver,
                  icon: gm.BitmapDescriptor.defaultMarkerWithHue(
                      gm.BitmapDescriptor.hueAzure),
                  infoWindow: const gm.InfoWindow(title: 'Vous'),
                ),
                gm.Marker(
                  markerId: const gm.MarkerId('pickup'),
                  position: pickup,
                  icon: gm.BitmapDescriptor.defaultMarkerWithHue(
                      gm.BitmapDescriptor.hueRed),
                  infoWindow: gm.InfoWindow(
                      title: pickupLabel?.trim().isNotEmpty == true
                          ? pickupLabel
                          : 'Point de retrait'),
                ),
              },
              polylines: {
                gm.Polyline(
                  polylineId: const gm.PolylineId('driver_to_pickup'),
                  points: [driver, pickup],
                  color: AppColors.primary,
                  width: 4,
                  patterns: [gm.PatternItem.dash(18), gm.PatternItem.gap(10)],
                ),
              },
              onMapCreated: (controller) async {
                // Fit both points once the map exists. Wrapped because a
                // freshly created lite-mode map can reject a camera update if
                // it hasn't laid out yet; a failure here should leave the
                // default camera, never break the dialog.
                try {
                  await controller
                      .animateCamera(gm.CameraUpdate.newLatLngBounds(_bounds, 24));
                } catch (e) {
                  debugPrint('OfferRoutePreview: camera fit failed: $e');
                }
              },
            ),
            // Dashed straight line is an as-the-crow-flies indication, not a
            // driving route. Say so, so nobody reads it as turn-by-turn.
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Distance à vol d\'oiseau',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String message) => Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.textLight.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 18, color: AppColors.textLight),
            const SizedBox(width: 6),
            Text(message,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
}
