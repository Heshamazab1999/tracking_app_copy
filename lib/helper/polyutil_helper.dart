import 'dart:math' as math;
import 'dart:math' show cos, sqrt, asin;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_app/helper/sound_helper.dart';

class PolyUtilHelper {
  final soundHelper = SoundHelper();

  bool isLocationOnPath(LatLng point, List<LatLng> polyline,
      {double tolerance = 50}) {
    if (polyline.isEmpty) {
      return false;
    }

    double distance =
        distanceToLine(point, polyline.first, polyline.last) * 1000;
    for (int i = 0; i < polyline.length - 1; i++) {
      double segmentDistance =
          distanceToLine(point, polyline[i], polyline[i + 1]) * 1000;
      // print(distance);
      if (segmentDistance < distance) {
        distance = segmentDistance;
      }
    }

    return distance <= tolerance;
  }

  double distanceToLine(LatLng point, LatLng start, LatLng end) {
    double d1 = math.sqrt(math.pow(point.latitude - start.latitude, 2) +
        math.pow(point.longitude - start.longitude, 2));
    double d2 = math.sqrt(math.pow(point.latitude - end.latitude, 2) +
        math.pow(point.longitude - end.longitude, 2));
    double d3 = math.sqrt(math.pow(start.latitude - end.latitude, 2) +
        math.pow(start.longitude - end.longitude, 2));
    double s = (d1 + d2 + d3) / 2;
    double area = math.sqrt(s * (s - d1) * (s - d2) * (s - d3));
    double distance = (2 * area / d3) * 1000;
    return distance;
  }

  Future<LatLng?> getClosestPoint(LatLng latLng, List<LatLng> points) async {
    double minDistance = 15;
    LatLng? closestPoint;
    for (LatLng point in points) {
      double distance = distanceBetweenPoints(latLng.latitude, latLng.longitude,
              point.latitude, point.longitude) *
          1000;
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }
    return closestPoint;
  }

  double distanceBetweenPoints(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
