import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:tracking_app/component/custom_button.dart';
import 'package:tracking_app/controller/map_controller.dart';
import 'package:tracking_app/enum/view_state.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/auth/sign_in_screen.dart';
import 'package:tracking_app/screen/map_screen/map_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/dimensions.dart';
import 'package:tracking_app/util/images.dart';
import 'package:tracking_app/util/styles.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapController());
    return SafeArea(
        child: Scaffold(
      body: Obx(() => controller.state == ViewState.busy
          ? const Center(
              child: SpinKitFadingCube(
                color: Color(0xff008d36),
                size: 50.0,
              ),
            )
          : controller.directionsModel?.districtLocations == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: Dimensions.height * 0.25,
                      child: Stack(
                        children: [
                          Container(
                            height: Dimensions.height * 0.2,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: Color(0xff008d36),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(70),
                                    bottomRight: Radius.circular(70))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "اهلا : ${CacheHelper.getData(key: AppConstants.name)}",
                                      style: robotoRegular.copyWith(
                                          color: Colors.white, fontSize: 20)),
                                  IconButton(
                                      onPressed: () {
                                        CacheHelper.clearData();
                                        Get.offAll(() => const SignInScreen());
                                      },
                                      icon: Image.asset(Images.logIcon))
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Image.asset(
                              Images.logo,
                              height: 100,
                            ),
                          )
                        ],
                      ),
                    ),
                    Lottie.asset(Images.noData),
                    Text("لاتوجد مسارات متاحه",
                        style: robotoRegular.copyWith(
                            color: const Color(0xff008d36), fontSize: 18)),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      height: Dimensions.height * 0.25,
                      child: Stack(
                        children: [
                          Container(
                            height: Dimensions.height * 0.2,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: Color(0xff008d36),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(70),
                                    bottomRight: Radius.circular(70))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "اهلا : ${CacheHelper.getData(key: AppConstants.name)}",
                                      style: robotoRegular.copyWith(
                                          color: Colors.white, fontSize: 20)),
                                  IconButton(
                                      onPressed: () {
                                        CacheHelper.clearData();
                                        Get.offAll(() => const SignInScreen());
                                      },
                                      icon: Image.asset(Images.logIcon))
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Image.asset(
                              Images.logo,
                              height: 100,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height * 0.04,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.directionsModel?.status == 0) {
                            Get.defaultDialog(
                                radius: 6,
                                title: "يجب حجز المسار اولا",
                                titleStyle: const TextStyle(
                                    color: Colors.red, fontSize: 20),
                                content: Lottie.asset(Images.error, height: 90),
                                confirm: SizedBox(
                                  width: 120,
                                  child: TextButton(
                                      onPressed: () async {
                                        controller.bookMission();
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff008d36)),
                                      child: const Text(
                                        "حجز",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      )),
                                ));
                          } else if (controller.longitudeContinue.value !=
                                  0.0 &&
                              controller.longitudeContinue.value != 0.0 &&
                              controller.distanceContinue.value > 70) {
                            Get.defaultDialog(
                                radius: 6,
                                title:
                                    "انت بعيد عن نقطه التوقف بمسافه\n ${controller.distanceContinue.value.toStringAsFixed(2)} م ",
                                titleStyle: const TextStyle(
                                    color: Colors.amber, fontSize: 18),
                                content: const Text(""),
                                confirm: SizedBox(
                                  width: 150,
                                  child: TextButton(
                                      onPressed: () async {
                                        controller.openMap(
                                            latLng: LatLng(
                                                controller
                                                    .latitudeContinue.value,
                                                controller
                                                    .longitudeContinue.value));
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff008d36)),
                                      child: const Text(
                                        "اذهب لنقطه الاستكمال",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      )),
                                ));
                          } else if (controller.userDistance.value > 500) {
                            Get.defaultDialog(
                                radius: 6,
                                title:
                                    "انت بعيد عن بدايه المسار بمسافه ${controller.userDistance.value.toStringAsFixed(2)}",
                                titleStyle: const TextStyle(
                                    color: Colors.green, fontSize: 18),
                                content: const Text(""),
                                confirm: SizedBox(
                                  width: 150,
                                  child: TextButton(
                                      onPressed: () async {
                                        controller.openMap(
                                            latLng: LatLng(
                                                controller
                                                    .directionsModel!
                                                    .districtLocations!
                                                    .first
                                                    .lat!,
                                                controller
                                                    .directionsModel!
                                                    .districtLocations!
                                                    .first
                                                    .long!));
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff008d36)),
                                      child: const Text(
                                        "اذهب لنقطه البدايه",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      )),
                                ));
                          } else {
                            Get.to(() => const MapScreen());
                          }
                        },
                        child: Card(
                          elevation: 2,
                          shadowColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.grey,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "الحى : ${controller.directionsModel?.districtName}",
                                        style: robotoRegular.copyWith(
                                            color: const Color(0xff008d36),
                                            fontSize: 16)),
                                    Text(
                                        "رقم المسار : ${controller.directionsModel?.routeNumber}",
                                        style: robotoRegular.copyWith(
                                            color: const Color(0xff008d36),
                                            fontSize: 16)),
                                    Text(
                                        "المسافه :  ${controller.userDistance.value.toStringAsFixed(3)}",
                                        style: robotoRegular.copyWith(
                                            color: const Color(0xff008d36),
                                            fontSize: 16))
                                  ],
                                ),
                                Obx(() => controller.bookValue.value
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xff008d36),
                                        ),
                                      )
                                    : CustomButton(
                                        color: const Color(0xff008d36)
                                            .withOpacity(0.9),
                                        buttonText: controller
                                                    .directionsModel?.status ==
                                                0
                                            ? "حجز المسار"
                                            : "استكمال المسار",
                                        onPressed: () {
                                          controller.directionsModel?.status ==
                                                  0
                                              ? controller.bookMission()
                                              : {
                                                  //   if (controller
                                                  //           .userDistance.value >
                                                  //       500)
                                                  //     {
                                                  //       Get.defaultDialog(
                                                  //           radius: 6,
                                                  //           title:
                                                  //               "انت بعيد عن بدايه المسار بمسافه ${controller.userDistance.value.toStringAsFixed(2)}",
                                                  //           titleStyle:
                                                  //               const TextStyle(
                                                  //                   color: Colors
                                                  //                       .green,
                                                  //                   fontSize: 18),
                                                  //           content:
                                                  //               const Text(""),
                                                  //           confirm: SizedBox(
                                                  //             width: 120,
                                                  //             child: TextButton(
                                                  //                 onPressed:
                                                  //                     () async {
                                                  //                   controller
                                                  //                       .openMap();
                                                  //                 },
                                                  //                 style: TextButton.styleFrom(
                                                  //                     backgroundColor:
                                                  //                         const Color(
                                                  //                             0xff008d36)),
                                                  //                 child:
                                                  //                     const Text(
                                                  //                   "اذهب للبدايه",
                                                  //                   style: TextStyle(
                                                  //                       color: Colors
                                                  //                           .white,
                                                  //                       fontSize:
                                                  //                           16),
                                                  //                 )),
                                                  //           ))
                                                  //     }
                                                  //   else
                                                  //     {
                                                  //       Get.to(() =>
                                                  //           const MapScreen()),
                                                  //     }
                                                  // };
                                                  if (controller.longitudeContinue.value != 0.0 &&
                                                      controller
                                                              .longitudeContinue
                                                              .value !=
                                                          0.0 &&
                                                      controller
                                                              .distanceContinue
                                                              .value >
                                                          70)
                                                    {
                                                      Get.defaultDialog(
                                                          radius: 6,
                                                          title:
                                                              "انت بعيد عن نقطه التوقف بمسافه\n ${controller.distanceContinue.value.toStringAsFixed(2)} م ",
                                                          titleStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .amber,
                                                                  fontSize: 18),
                                                          content:
                                                              const Text(""),
                                                          confirm: SizedBox(
                                                            width: 150,
                                                            child: TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  controller.openMap(
                                                                      latLng: LatLng(
                                                                          controller
                                                                              .latitudeContinue
                                                                              .value,
                                                                          controller
                                                                              .longitudeContinue
                                                                              .value));
                                                                },
                                                                style: TextButton.styleFrom(
                                                                    backgroundColor:
                                                                        const Color(
                                                                            0xff008d36)),
                                                                child:
                                                                    const Text(
                                                                  "اذهب لنقطه الاستكمال",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                          )),
                                                    }
                                                  else if (controller
                                                          .userDistance.value >
                                                      500)
                                                    {
                                                      Get.defaultDialog(
                                                          radius: 6,
                                                          title:
                                                              "انت بعيد عن بدايه المسار بمسافه ${controller.userDistance.value.toStringAsFixed(2)}",
                                                          titleStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize: 18),
                                                          content:
                                                              const Text(""),
                                                          confirm: SizedBox(
                                                            width: 150,
                                                            child: TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  controller.openMap(
                                                                      latLng: LatLng(
                                                                          controller
                                                                              .directionsModel!
                                                                              .districtLocations!
                                                                              .first
                                                                              .lat!,
                                                                          controller
                                                                              .directionsModel!
                                                                              .districtLocations!
                                                                              .first
                                                                              .long!));
                                                                },
                                                                style: TextButton.styleFrom(
                                                                    backgroundColor:
                                                                        const Color(
                                                                            0xff008d36)),
                                                                child:
                                                                    const Text(
                                                                  "اذهب لنقطه البدايه",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                          )),
                                                    }
                                                  else
                                                    {
                                                      Get.to(() =>
                                                          const MapScreen()),
                                                    }
                                                };
                                        },
                                        width: Dimensions.width * 0.3,
                                        height: Dimensions.height * 0.05,
                                      ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => (controller.latitudeContinue.value == 0.0 &&
                            controller.longitudeContinue.value == 0.0)
                        ? Expanded(
                            child: GoogleMap(
                                zoomControlsEnabled: true,
                                markers: {...controller.markers},
                                polylines:
                                    Set<Polyline>.of(controller.polyline),
                                gestureRecognizers: {}
                                  ..add(Factory<PanGestureRecognizer>(
                                      () => PanGestureRecognizer()))
                                  ..add(Factory<ScaleGestureRecognizer>(
                                      () => ScaleGestureRecognizer()))
                                  ..add(Factory<TapGestureRecognizer>(
                                      () => TapGestureRecognizer()))
                                  ..add(Factory<VerticalDragGestureRecognizer>(
                                      () => VerticalDragGestureRecognizer())),
                                myLocationEnabled: true,
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(controller.position.latitude,
                                        controller.position.longitude),
                                    zoom: 18)),
                          )
                        : Expanded(
                            child: GoogleMap(
                                zoomControlsEnabled: true,
                                markers: {...controller.markersContinue},
                                // polylines:
                                //     Set<Polyline>.of(controller.polyline),
                                gestureRecognizers: {}
                                  ..add(Factory<PanGestureRecognizer>(
                                      () => PanGestureRecognizer()))
                                  ..add(Factory<ScaleGestureRecognizer>(
                                      () => ScaleGestureRecognizer()))
                                  ..add(Factory<TapGestureRecognizer>(
                                      () => TapGestureRecognizer()))
                                  ..add(Factory<VerticalDragGestureRecognizer>(
                                      () => VerticalDragGestureRecognizer())),
                                myLocationEnabled: true,
                                onMapCreated: (map) {
                                  map.showMarkerInfoWindow(controller
                                      .markersContinue.first.markerId);
                                },
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        controller.latitudeContinue.value,
                                        controller.longitudeContinue.value),
                                    zoom: 18)),
                          ))
                  ],
                )),
    ));
  }
}
