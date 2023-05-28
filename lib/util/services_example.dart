// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MyMap extends StatefulWidget {
//   @override
//   _MyMapState createState() => _MyMapState();
// }
//
// class _MyMapState extends State<MyMap> {
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   final List<LatLng> _routePoints = [
//     const LatLng(37.422, -122.084),
//     const LatLng(37.421, -122.085),
//     const LatLng(37.420, -122.086),
//     const LatLng(37.419, -122.087),
//   ];
//
//   late LatLng _currentLocation;
//   bool _isOnRoute = false;
//
//   late GoogleMapController _mapController;
//
//   // late Position _location ;
//   StreamSubscription<Position>? positionStream;
//
//   @override
//   void initState() {
//     super.initState();
//     positionStream = Geolocator.getPositionStream(
//             locationSettings:
//                 const LocationSettings(accuracy: LocationAccuracy.best))
//         .listen((event) {
//       _currentLocation = LatLng(
//         event.latitude,
//         event.longitude,
//       );
//       _addMarker(_currentLocation);
//       _moveCamera(_currentLocation);
//       _checkOnRoute();
//     });
//   }
//
//   void _addMarker(LatLng location) {
//     setState(() {
//       _markers.add(Marker(
//         markerId: const MarkerId("user"),
//         position: location,
//       ));
//     });
//   }
//
//   void _moveCamera(LatLng location) {
//     _mapController.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: location,
//         zoom: 16.0,
//       ),
//     ));
//   }
//
//   void _checkOnRoute() {
//     double minDistance = double.infinity;
//     for (int i = 0; i < _routePoints.length - 1; i++) {
//       LatLng p1 = _routePoints[i];
//       LatLng p2 = _routePoints[i + 1];
//       double distance = _distanceToLine(_currentLocation, p1, p2);
//       if (distance < minDistance) {
//         minDistance = distance;
//       }
//     }
//     setState(() {
//       _isOnRoute = minDistance < 10; // If user is within 10 meters of the route
//       if (_isOnRoute) {
//         _polylines.add(Polyline(
//           polylineId: const PolylineId("route"),
//           points: _routePoints,
//           color: Colors.blue,
//           width: 5,
//         ));
//       }
//     });
//   }
//
//   double _distanceToLine(LatLng point, LatLng p1, LatLng p2) {
//     double x = point.latitude;
//     double y = point.longitude;
//     double x1 = p1.latitude;
//     double y1 = p1.longitude;
//     double x2 = p2.latitude;
//     double y2 = p2.longitude;
//     double num = ((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1).abs();
//     double den = sqrt(pow(y2 - y1, 2) + pow(x2 - x1, 2));
//     return num / den;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         markers: _markers,
//         polylines: _polylines,
//         initialCameraPosition: const CameraPosition(
//           target: LatLng(37.4219999, -122.0840575),
//           zoom: 16.0,
//         ),
//         onMapCreated: (GoogleMapController controller) {
//           _mapController = controller;
//         },
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             _isOnRoute ? "On Route" : "Off Route",
//             style: const TextStyle(fontSize: 20),
//           ),
//         ),
//       ),
//     );
//   }
// }
