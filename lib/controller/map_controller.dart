import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:tracking_app/controller/base_controller.dart';
import 'package:tracking_app/enum/view_state.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/helper/polyutil_helper.dart';
import 'package:tracking_app/helper/sound_helper.dart';
import 'package:tracking_app/model/info_model.dart';
import 'package:tracking_app/model/path_model.dart';
import 'package:tracking_app/screen/home_screen/home_screen.dart';
import 'package:tracking_app/services/map_services.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/images.dart';

class MapController extends BaseController {
  static MapController to = Get.find();
  final services = MapServices();
  final util = PolyUtilHelper();
  final soundHelper = SoundHelper();
  late Position position;
  StreamSubscription<Position>? positionStreamSubscription;
  StreamSubscription<Position>? positionStream;
  final currentLocationMarker = const Marker(
    markerId: MarkerId('currentLocation'),
    position: LatLng(0, 0),
  ).obs;
  final markers = <Marker>{}.obs;
  final markersContinue = <Marker>{}.obs;
  final polyline = <Polyline>{}.obs;
  final streamPoint = <LatLng>[].obs;
  final pathPoint = <LatLng>[].obs;
  final polylineCoordinates = <LatLng>[].obs;
  Completer<GoogleMapController> completer = Completer();
  DirectionsModel? directionsModel;
  final statusId = 0.obs;
  final missionValue = 0.obs;
  final userDistance = 0.0.obs;
  final infoList = <InfoModel>[].obs;
  Timer? timer;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final locationMarker = true.obs;
  final bookValue = false.obs;
  late PolylinePoints polylinePoints;
  final latitudeContinue = 0.0.obs;
  final longitudeContinue = 0.0.obs;
  final distanceContinue = 0.0.obs;
  final distanceExploration = 0.0.obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    setState(ViewState.busy);
    await determinePosition();
    await getPaths();
    setState(ViewState.idle);
  }

  getPaths() async {
    //directionsModel = await testData();
    directionsModel = await services.getPaths(position: position);
    if (directionsModel?.districtLocations != null) {
      await createPolyline();
      await distanceBetweenLocations();
      await drawPolyLineMission();
      await getObjectZero();
      await addMarkersExploration();

      if (directionsModel?.status == 3) {
        CacheHelper.saveData(key: AppConstants.missionVaValue, value: 3);
      }
      missionValue.value =
          CacheHelper.getData(key: AppConstants.missionVaValue) ?? 0;
    } else {
      CacheHelper.saveData(key: AppConstants.missionVaValue, value: 0);
    }
  }

  testData() {
    directionsModel = DirectionsModel(
        status: 3,
        routeNumber: 1,
        districtId: 1,
        districtName: "birket",
        districtLocations: [
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "s",
            objectId: 1,
            lat: 30.629651,
            long: 31.079462,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "c",
            objectId: 1,
            lat: 30.629709,
            long: 31.079129,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "l",
            objectId: 1,
            lat: 30.629787,
            long: 31.078822,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "c",
            objectId: 1,
            lat: 30.629967,
            long: 31.078968,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "l",
            objectId: 1,
            lat: 30.630093,
            long: 31.079094,
          ),
          // DistrictLocations(
          //   districtId: 1,
          //   routeNumber: 1,
          //   description: "l",
          //   objectId: 0,
          //   lat: 30.630093,
          //   long: 31.079094,
          // ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "c",
            objectId: 1,
            lat: 30.630061,
            long: 31.079404,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "l",
            objectId: 1,
            lat: 30.630029,
            long: 31.079700,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "e",
            objectId: 1,
            lat: 30.629874,
            long: 31.079663,
          ),
        ]);
    return directionsModel;
  }

  distanceBetweenLocations() {
    userDistance.value = util.distanceBetweenPoints(
          position.latitude,
          position.longitude,
          directionsModel?.districtLocations?.first.lat ?? 0.0,
          directionsModel?.districtLocations?.first.long ?? 0.0,
        ) *
        1000;
    print("userDistance${userDistance.value}");
  }

  checkUserInLocation() {
    if (userDistance.value > 70) {
      Get.defaultDialog(
          barrierDismissible: false,
          radius: 6,
          title: "اذهب الى بدايه المسار",
          content: SizedBox(
            width: 120,
            child: TextButton(
                onPressed: () {
                  positionStream = Geolocator.getPositionStream(
                          locationSettings: const LocationSettings(
                              accuracy: LocationAccuracy.high))
                      .listen((event) {
                    if (util.distanceBetweenPoints(
                                event.latitude,
                                event.longitude,
                                directionsModel?.districtLocations?.first.lat ??
                                    0.0,
                                directionsModel
                                        ?.districtLocations?.first.long ??
                                    0.0) *
                            1000 >=
                        70) {
                      CacheHelper.saveData(
                          key: AppConstants.missionVaValue, value: 0);
                      missionValue.value =
                          CacheHelper.getData(key: AppConstants.missionVaValue);
                    } else {
                      CacheHelper.getData(key: AppConstants.missionVaValue) == 3
                          ? {
                              {
                                CacheHelper.saveData(
                                    key: AppConstants.missionVaValue, value: 3),
                                missionValue.value = CacheHelper.getData(
                                    key: AppConstants.missionVaValue)
                              }
                            }
                          : {
                              CacheHelper.saveData(
                                  key: AppConstants.missionVaValue, value: 1),
                              missionValue.value = CacheHelper.getData(
                                  key: AppConstants.missionVaValue)
                            };
                    }
                    animateTo(event.latitude ?? 0.0, event.longitude,
                        bearing: event.heading);
                  });
                  Get.back();
                },
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff008d36)),
                child: const Text(
                  "تأكيد",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
          ));
    } else {
      CacheHelper.getData(key: AppConstants.missionVaValue) == 3
          ? {
              CacheHelper.saveData(key: AppConstants.missionVaValue, value: 3),
              missionValue.value =
                  CacheHelper.getData(key: AppConstants.missionVaValue)
            }
          : {
              CacheHelper.saveData(key: AppConstants.missionVaValue, value: 1),
              missionValue.value =
                  CacheHelper.getData(key: AppConstants.missionVaValue)
            };
    }
  }

  drawPolyLineMission() async {
    directionsModel?.districtLocations?.forEach((element) {
      if (element.objectId == 0) {
      } else {
        pathPoint.add(LatLng(element.lat ?? 0.0, element.long ?? 0.0));
        polyline.add(Polyline(
            polylineId: const PolylineId("2"),
            color: Colors.red,
            width: 6,
            points: pathPoint));
      }
    });
    final Uint8List markerStartEnd =
        await util.getBytesFromAsset(Images.startIcon, 80);
    BitmapDescriptor start = BitmapDescriptor.fromBytes(markerStartEnd);
    final Uint8List markerIconEnd =
        await util.getBytesFromAsset(Images.endIcon, 80);
    BitmapDescriptor end = BitmapDescriptor.fromBytes(markerIconEnd);
    markers.add(Marker(
        markerId: const MarkerId("1"),
        icon: start,
        position: LatLng(directionsModel?.districtLocations?.first.lat ?? 0.0,
            directionsModel?.districtLocations?.first.long ?? 0)));
    markers.add(Marker(
        markerId: const MarkerId("1"),
        icon: end,
        position: LatLng(directionsModel?.districtLocations?.last.lat ?? 0.0,
            directionsModel?.districtLocations?.last.long ?? 0)));
  }

  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
    return position;
  }

  startMission() async {
    locationMarker.value = false;
    await startLocationTracking().then((value) {
      timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (latitude.value == 0.0 && longitude.value == 0.0) {
        } else {
          getIndexPoint(LatLng(latitude.value, longitude.value));
          infoList.add(InfoModel(
              time: DateTime.now().toString(),
              districtId: directionsModel?.districtId,
              status: statusId.value,
              routeNumber: directionsModel?.routeNumber,
              latitude: latitude.value,
              longitude: longitude.value));
          await services.addVehicleInfo(data: infoList);
          infoList.clear();
          solveLocations();
        }
      });
      // timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      //   // print("length:${infoList.length} ");
      //   // for (var element in infoList) {
      //   //   print(element.toJson());
      //   // }
      //   await services.addVehicleInfo(data: infoList);
      //   infoList.clear();
      // });
    });
  }

  Future<void> startLocationTracking() async {
    positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high))
        .listen((position) {
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      streamPoint.add(LatLng(position.latitude, position.longitude));
      myMarker(position, position.heading);
      animateTo(position.latitude, position.longitude,
          bearing: position.heading);
      drawPolyLine(points: streamPoint);
      checkLocation(LatLng(position.latitude, position.longitude));
    });
  }

  checkLocation(LatLng latLng) {
    bool isNearPolyline = util.isLocationOnPath(
      latLng,
      pathPoint,
      tolerance: 70,
    );
    if (isNearPolyline) {
      CacheHelper.saveData(key: AppConstants.missionVaValue, value: 2);
      missionValue.value =
          CacheHelper.getData(key: AppConstants.missionVaValue);
      print("object");
      statusId.value = 1;
      for (int i = 0; i < directionsModel!.districtLocations!.length; i++) {
        if (directionsModel!.districtLocations![i].description != null) {
          playSound(
              directionsModel!.districtLocations![i].description!,
              latLng,
              directionsModel!.districtLocations![i].lat ?? 0.0,
              directionsModel!.districtLocations![i].long ?? 0.0);
        }
      }
    } else {
      statusId.value = 4;
      print("false");
    }
  }

  getObjectZero() {
    directionsModel?.districtLocations?.forEach((element) {
      if (element.objectId == 0) {
        latitudeContinue.value = element.lat!;
        longitudeContinue.value = element.long!;
        // print(element.lat);
        // print(element.long);
        // print(element.objectId);
        // print(element.description);
        distanceContinue.value = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            latitudeContinue.value,
            longitudeContinue.value);
        // print(distanceContinue.value);
        markersContinue.add(Marker(
            markerId: MarkerId(
              "${element.objectId}",
            ),
            onTap: () async {
              await openMap(
                  latLng:
                      LatLng(latitudeContinue.value, longitudeContinue.value));
            },
            infoWindow: const InfoWindow(
              title: ' نقطه الاستكمال',
            ),
            position: LatLng(latitudeContinue.value, longitudeContinue.value)));
        // print("true");
      }
    });
  }

  getIndexPoint(LatLng latLng) async {
    LatLng? closestPoint = await util.getClosestPoint(latLng, pathPoint);
    print('Closest point: $closestPoint');
    if (closestPoint != null) {
      int? index = pathPoint.indexWhere((element) => element == closestPoint);
      print('Index: $index');
      await services.sendPoints(
          districtId: directionsModel?.districtId,
          routeNumber: directionsModel?.routeNumber,
          objectId: directionsModel?.districtLocations![index].objectId);
    }
  }

  playSound(String char, LatLng event, double lat, double long) async {
    switch (char) {
      case "s":
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          soundHelper.playerAudioStart();
          break;
        }

        break;
      case "r":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.turnRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnRight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "l":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.left, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnLeft();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }

        break;
      case "u":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.returnImage, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioUTurn();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "ub":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.turnBack, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioTurnBack();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }

        break;
      case "c":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.goStraight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioStraight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "ss":
        // final Uint8List markerIconEnd =
        //     await util.getBytesFromAsset(Images.goStraight, 80);
        // BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          // markers.add(
          //   Marker(
          //       markerId: MarkerId("$lat"),
          //       position: LatLng(lat, long),
          //       icon: navigate),
          // );
          soundHelper.playerNewStart();
          break;
        } else {
          // markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "rr":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.turnRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude ?? 0.0, event.longitude ?? 0.0, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnRight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "ll":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.left, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude ?? 0.0, event.longitude ?? 0.0, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnLeft();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "rl":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.leftAndRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude ?? 0.0, event.longitude ?? 0.0, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnLeft();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "lr":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.leftAndRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnRight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "e":
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          print(Geolocator.distanceBetween(
              event.latitude, event.longitude, lat, long));
          soundHelper.playerAudioFinish();
          CacheHelper.saveData(key: AppConstants.missionVaValue, value: 4);
          missionValue.value =
              CacheHelper.getData(key: AppConstants.missionVaValue);
          break;
        } else {
          // CacheHelper.saveData(key: AppConstants.missionVaValue, value: 0);
          // // SharedPref.setSelectedMissionValue(0);
          // missionValue.value =
          //     CacheHelper.getData(key: AppConstants.missionVaValue);
        }
        break;
    }
  }

  stopMission() async {
    await services.stopMission();
  }

  pauseMission() async {
    await services.continueMission();
  }

  endMission() async {
    await services.end();
  }

  bookMission() async {
    try {
      bookValue.value = true;
      await services.bookPath(
          routeNumber: directionsModel?.routeNumber,
          districtId: directionsModel?.districtId);
      bookValue.value = false;
    } catch (e) {
      bookValue.value = false;
    }
  }

  Future<void> animateTo(double latitude, double longitude,
      {double? bearing}) async {
    final googleMapController = await completer.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              latitude,
              longitude,
            ),
            bearing: bearing ?? 90,
            zoom: 18,
            tilt: 30)));
  }

  drawPolyLine({List<LatLng>? points}) {
    polyline.add(Polyline(
        polylineId: const PolylineId("1"),
        width: 4,
        color: Colors.green,
        points: points ?? []));
  }

  myMarker(Position event, double rotate) async {
    final Uint8List markerIconEnd =
        await util.getBytesFromAsset(Images.track, 50);
    BitmapDescriptor end = BitmapDescriptor.fromBytes(markerIconEnd);
    currentLocationMarker.value = Marker(
      markerId: MarkerId("$event"),
      rotation: rotate,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      position: LatLng(event.latitude, event.longitude),
      infoWindow: const InfoWindow(
        title: "موقعك الحالى",
        snippet: "موقعك الحالى",
      ),
      icon: end,
    );
  }

  functionButton() async {
    switch (missionValue.value) {
      case 1:
        positionStream?.cancel();
        services.startMission();
        startMission();
        break;
      case 2:
        Get.defaultDialog(
            radius: 6,
            title: "ايقاف مؤقت",
            titleStyle: const TextStyle(color: Colors.red, fontSize: 18),
            content: const Text(""),
            // content: Text(
            //   " لقد قطعت مسافه ${userDistance.round() / 1000} كم من طول المسار ",
            //   style: const TextStyle(color: Color(0xff008d36), fontSize: 18),
            // ),
            confirm: SizedBox(
              width: 120,
              child: TextButton(
                  onPressed: () async {
                    timer?.cancel();
                    positionStream?.cancel();
                    positionStreamSubscription?.cancel();
                    await stopMission();
                    CacheHelper.saveData(
                        key: AppConstants.missionVaValue, value: 3);
                    soundHelper.player.dispose();
                    completer = Completer();
                    latitude.value = 0.0;
                    longitude.value = 0.0;
                    Get.offAll(() => const HomeScreen());
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff008d36)),
                  child: const Text(
                    "تأكيد",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ));
        break;
      case 3:
        pauseMission();
        startMission();
        positionStream?.cancel();
        break;
      case 4:
        positionStream?.cancel();
        positionStreamSubscription?.cancel();
        timer?.cancel();
        completer = Completer();
        soundHelper.player.dispose();
        Get.defaultDialog(
            radius: 6,
            title: 'انهاء المهمه'.tr,
            titleStyle: const TextStyle(color: Colors.red, fontSize: 18),
            content: const Text(""),
            confirm: SizedBox(
              width: 120,
              child: TextButton(
                  onPressed: () async {
                    endMission();
                    CacheHelper.saveData(
                        key: AppConstants.missionVaValue, value: 0);
                    await services.completeTask(
                        districtId: directionsModel!.districtId!,
                        routeId: directionsModel!.routeNumber!);
                    Get.delete<MapController>();
                    latitude.value = 0.0;
                    longitude.value = 0.0;
                    Get.to(() => const HomeScreen());
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff008d36)),
                  child: const Text(
                    "انهاء",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ));
      // Get.defaultDialog(
      //     title: 'انهاء المهمه'.tr,
      //     content: const Text(""),
      //     confirm: InkWell(onTap: () async {
      //       endMission();
      //       CacheHelper.saveData(key: AppConstants.missionVaValue, value: 0);
      //       await services.completeTask(
      //           districtId: directionsModel!.districtId!,
      //           routeId: directionsModel!.routeNumber!);
      //       Get.delete<MapController>();
      //       latitude.value = 0.0;
      //       longitude.value = 0.0;
      //       Get.to(() => const HomeScreen());
      //     }));
    }
  }

  createPolyline() async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      AppConstants.apiKey,
      PointLatLng(position.latitude, position.longitude),
      PointLatLng(directionsModel!.districtLocations!.first.lat!,
          directionsModel!.districtLocations!.first.long!),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    polyline.add(Polyline(
      polylineId: const PolylineId('2'),
      color: Colors.amber,
      points: polylineCoordinates,
      width: 4,
    ));
  }

  openMap({LatLng? latLng}) async {
    final availableMaps = await MapLauncher.installedMaps;
    for (var map in availableMaps) {
      map.showDirections(
        origin: Coords(position.latitude, position.longitude),
        directionsMode: DirectionsMode.driving,
        destination: Coords(latLng?.latitude ?? 0.0, latLng?.longitude ?? 0.0),
        // waypoints: waypoints
      );
    }
  }

  solveLocations() {
    directionsModel?.closestLocation?.forEach((elementExploration) {
      if (elementExploration.type == 2) {
      } else {
        if (directionsModel!.closestLocation!.isEmpty) {
        } else {
          distanceExploration.value = Geolocator.distanceBetween(
              latitude.value,
              longitude.value,
              elementExploration.latitude ?? 0.0,
              elementExploration.longitude ?? 0.0);
          if (distanceExploration.value <= 60) {
            services.solveLocation(
              id: elementExploration.locationId!,
              type: elementExploration.type!,
            );
            markers.removeWhere((maker) =>
                maker.position ==
                LatLng(elementExploration.latitude ?? 0.0,
                    elementExploration.longitude ?? 0.0));
            directionsModel?.closestLocation?.remove(elementExploration);
          }
        }
      }
    });
  }

  addMarkersExploration() async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/b1.png',
    );
    directionsModel?.closestLocation?.forEach((element) async {
      if (element.type == 2) {
        // final Uint8List markerIcon =
        // await getBytesFromAsset('assets/images/error.png', 80);
        // BitmapDescriptor icon940 = BitmapDescriptor.fromBytes(markerIcon);
        // markers.add(Marker(
        //     markerId: MarkerId("${element.locationId}"),
        //     onTap: () {
        //       Get.defaultDialog(
        //         radius: 6,
        //         title: "اضافه اجراء",
        //         titleStyle:
        //         const TextStyle(fontSize: 20, color: lightPrimaryColor),
        //         content: SingleChildScrollView(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Padding(
        //                 padding: const EdgeInsets.all(8.0),
        //                 child: Text(
        //                   "اضافه صور".tr,
        //                   style: const TextStyle(
        //                       color: lightPrimaryColor,
        //                       fontSize: 16,
        //                       fontWeight: FontWeight.bold),
        //                 ),
        //               ),
        //               Center(
        //                 child: SizedBox(
        //                   height: 80,
        //                   width: Get.width - 50,
        //                   child: Row(
        //                     children: [
        //                       Expanded(
        //                           child: Obx(
        //                                 () => ListView.builder(
        //                                 physics: const BouncingScrollPhysics(),
        //                                 itemCount: imagesList.length,
        //                                 scrollDirection: Axis.horizontal,
        //                                 itemBuilder: (context, index) {
        //                                   return Stack(
        //                                     alignment: Alignment.topLeft,
        //                                     children: [
        //                                       Container(
        //                                         margin: const EdgeInsets.symmetric(
        //                                             vertical: 8, horizontal: 8),
        //                                         width: MediaQuery.of(context)
        //                                             .size
        //                                             .width /
        //                                             5,
        //                                         height: MediaQuery.of(context)
        //                                             .size
        //                                             .height /
        //                                             8,
        //                                         decoration: BoxDecoration(
        //                                             color: Colors.grey,
        //                                             image: DecorationImage(
        //                                                 image: FileImage(
        //                                                     imagesList[index]),
        //                                                 fit: BoxFit.cover),
        //                                             borderRadius:
        //                                             BorderRadius.circular(5)),
        //                                       ),
        //                                       GestureDetector(
        //                                         onTap: () {
        //                                           deleteImages(index);
        //                                         },
        //                                         child: Container(
        //                                           width: 25,
        //                                           height: 25,
        //                                           decoration: const BoxDecoration(
        //                                               color: Colors.red,
        //                                               shape: BoxShape.circle),
        //                                           child: const Icon(Icons.clear,
        //                                               color: Colors.white),
        //                                         ),
        //                                       )
        //                                     ],
        //                                   );
        //                                 }),
        //                           )),
        //                       //! Add Icon
        //                       InkWell(
        //                         onTap: () {
        //                           selectImage();
        //                         },
        //                         child: Container(
        //                           margin:
        //                           const EdgeInsets.symmetric(horizontal: 8),
        //                           width: Get.width / 8,
        //                           height: Get.height / 8,
        //                           decoration: BoxDecoration(
        //                               color: lightPrimaryColor,
        //                               borderRadius: BorderRadius.circular(5)),
        //                           child: const Icon(
        //                             Icons.add_photo_alternate,
        //                             color: whiteColor,
        //                           ),
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //               const Divider(
        //                   endIndent: 25, indent: 25, color: lightPrimaryColor),
        //               Padding(
        //                 padding: const EdgeInsets.all(8.0),
        //                 child: Text(
        //                   "اتخاذ اجراء".tr,
        //                   style: const TextStyle(
        //                       color: lightPrimaryColor,
        //                       fontSize: 16,
        //                       fontWeight: FontWeight.bold),
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: 200,
        //                 height: 250,
        //                 child: ListView.builder(
        //                     itemCount: typesList.length,
        //                     shrinkWrap: true,
        //                     physics: const BouncingScrollPhysics(),
        //                     itemBuilder: (_, index) => Row(
        //                       children: [
        //                         Obx(() => Checkbox(
        //                             value: list[index],
        //                             onChanged: (v) {
        //                               list[index] = !list[index];
        //                               if (list[index] == true) {
        //                                 addIds(typesList[index].id);
        //                               } else {
        //                                 removeIds(typesList[index].id);
        //                               }
        //                             })),
        //                         Flexible(
        //                           child: Text(
        //                             typesList[index].name,
        //                             style: const TextStyle(
        //                                 color: Colors.black, fontSize: 18),
        //                           ),
        //                         )
        //                       ],
        //                     )),
        //               ),
        //               const Divider(
        //                   endIndent: 25, indent: 25, color: lightPrimaryColor),
        //               const SizedBox(
        //                 height: 15,
        //               ),
        //               Row(
        //                 children: [
        //                   Row(
        //                     children: [
        //                       Obx(() => Radio(
        //                           value: true,
        //                           groupValue: check.value,
        //                           toggleable: true,
        //                           activeColor: lightPrimaryColor,
        //                           onChanged: (bool? v) {
        //                             check.value = v ?? true;
        //                             print(check.value);
        //                           })),
        //                       const Text(
        //                         "تم التنفيذ",
        //                         style: TextStyle(
        //                             color: Colors.black, fontSize: 18),
        //                       )
        //                     ],
        //                   ),
        //                   Row(
        //                     children: [
        //                       Obx(() => Radio(
        //                           value: false,
        //                           groupValue: check.value,
        //                           toggleable: true,
        //                           activeColor: lightPrimaryColor,
        //                           onChanged: (bool? v) {
        //                             check.value = v ?? false;
        //                             print(check.value);
        //                           })),
        //                       const Text(
        //                         " لم يتم التنفيذ",
        //                         style: TextStyle(
        //                             color: Colors.black, fontSize: 18),
        //                       )
        //                     ],
        //                   )
        //                 ],
        //               ),
        //               Obx(() => loading.value
        //                   ? const Center(
        //                 child: CircularProgressIndicator(),
        //               )
        //                   : Center(
        //                 child: SizedBox(
        //                   width: 150,
        //                   child: TextButton(
        //                       onPressed: () {
        //                         addProcess(Get.context!,
        //                             element.locationId ?? 1);
        //                         Get.back();
        //                       },
        //                       style: TextButton.styleFrom(
        //                           backgroundColor: lightPrimaryColor,
        //                           shape: RoundedRectangleBorder(
        //                               borderRadius:
        //                               BorderRadius.circular(6))),
        //                       child: Text(
        //                         "اضافه".tr,
        //                         style:
        //                         const TextStyle(color: Colors.white),
        //                       )),
        //                 ),
        //               )),
        //               const SizedBox(
        //                 height: 15,
        //               )
        //             ],
        //           ),
        //         ),
        //       );
        //     },
        //     position: LatLng(element.latitude ?? 0.0, element.longitude ?? 0.0),
        //     icon: icon940));
      } else {
        markers.add(Marker(
          markerId: MarkerId("${element.locationId}"),
          position: LatLng(element.latitude ?? 0.0, element.longitude ?? 0.0),
          icon: markerbitmap,
        ));
      }
    });
    return markers;
  }
}
