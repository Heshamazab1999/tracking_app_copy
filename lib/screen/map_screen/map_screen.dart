import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_app/component/custom_button.dart';
import 'package:tracking_app/controller/map_controller.dart';
import 'package:tracking_app/enum/view_state.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/home_screen/home_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/styles.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Call your function here

      _myFunction();
    }
  }

  Future<void> _myFunction() async {
    CacheHelper.getData(key: AppConstants.missionVaValue) == 0
        ? {}
        : {
            print("_myFunction"),
            MapController.to.timer != null
                ? MapController.to.timer?.cancel()
                : {},
            MapController.to.positionStream?.cancel(),
            MapController.to.positionStreamSubscription?.cancel(),
            await MapController.to.stopMission(),
            CacheHelper.saveData(key: AppConstants.missionVaValue, value: 3),
            MapController.to.soundHelper.player.dispose(),
            MapController.to.completer = Completer(),
            MapController.to.latitude.value = 0.0,
            MapController.to.longitude.value = 0.0,
            // Do something here
          };
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
            body: Obx(
          () => controller.state == ViewState.busy
              ? const Center(
                  child: SpinKitFadingCube(
                    color: Color(0xff008d36),
                    size: 50.0,
                  ),
                )
              : WillPopScope(
                  onWillPop: () async {
                    return await Get.defaultDialog(
                        radius: 6,
                        title: 'ايقاف موقت',
                        titleStyle:
                            const TextStyle(color: Colors.red, fontSize: 18),
                        content: Text("هل تريد الايقاف المؤقت ؟ ",
                            style: robotoRegular.copyWith(
                                fontSize: 18, color: Colors.red)),
                        confirm: SizedBox(
                          width: 120,
                          child: TextButton(
                              onPressed: () async {
                                CacheHelper.getData(
                                            key: AppConstants.missionVaValue) ==
                                        0
                                    ? {
                                        Get.to(() => const HomeScreen()),
                                      }
                                    : {
                                        controller.timer?.cancel(),
                                        controller.positionStreamSubscription
                                            ?.cancel(),
                                        controller.positionStream?.cancel(),
                                        controller.endMission(),
                                        controller.soundHelper.player.dispose(),
                                        CacheHelper.saveData(
                                            key: AppConstants.missionVaValue,
                                            value: 3),
                                        controller.latitude.value = 0.0,
                                        controller.longitude.value = 0.0,
                                        Get.to(() => const HomeScreen()),
                                      };
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xff008d36)),
                              child: const Text(
                                "تأكيد",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )),
                        ));
                  },
                  child: Stack(
                    children: [
                      GoogleMap(
                        myLocationEnabled: controller.locationMarker.value,
                        mapType: MapType.normal,
                        zoomControlsEnabled: true,
                        initialCameraPosition: CameraPosition(
                            zoom: 16,
                            target: LatLng(controller.position.latitude,
                                controller.position.longitude)),
                        polylines: Set<Polyline>.of(controller.polyline),
                        markers: <Marker>{
                          ...controller.markers,
                          controller.currentLocationMarker.value,
                          controller.markersContinue.isEmpty
                              ? const Marker(markerId: MarkerId("0"))
                              : controller.markersContinue.first,
                        },
                        onMapCreated: (map) async {
                          controller.completer.complete(map);
                          await controller.checkUserInLocation();
                          controller.markersContinue.isEmpty
                              ? null
                              : map.showMarkerInfoWindow(
                                  controller.markersContinue.first.markerId);
                        },
                      ),
                      Positioned(
                          bottom: 20,
                          right: 20,
                          left: 20,
                          child: Obx(
                            () => controller.missionValue.value == 0
                                ? const SizedBox()
                                : CustomButton(
                                    color: controller.missionValue.value == 1
                                        ? const Color(0xff008d36)
                                            .withOpacity(0.9)
                                        : controller.missionValue.value == 2
                                            ? Colors.red
                                            : controller.missionValue.value == 3
                                                ? Colors.amber
                                                : controller.missionValue
                                                            .value ==
                                                        4
                                                    ? Colors.red
                                                    : Colors.transparent,
                                    buttonText: controller.missionValue.value ==
                                            1
                                        ? "ابداء المهمه"
                                        : controller.missionValue.value == 2
                                            ? "ايقاف مؤقت"
                                            : controller.missionValue.value == 3
                                                ? "استكمال المسار"
                                                : controller.missionValue
                                                            .value ==
                                                        4
                                                    ? "انهاء المهمه"
                                                    : "",
                                    onPressed: () {
                                      controller.functionButton();
                                    },
                                  ),
                          ))
                    ],
                  ),
                ),
        )),
      );
    });
  }
}
