import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tracking_app/component/custom_snackbar.dart';
import 'package:tracking_app/helper/dio_integration.dart';
import 'package:tracking_app/model/info_model.dart';
import 'package:tracking_app/model/path_model.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/utility.dart';

class MapServices {
  final dio = DioUtilNew.dio;

  getPaths({Position? position}) async {
    try {
      final response = await dio!.get(
          "${AppConstants.getPaths}ULat=${position?.latitude}&ULong=${position?.longitude}");
      if (response.statusCode == 200) {
        DirectionsModel directionsModel =
            DirectionsModel.fromJson(response.data);
        print(directionsModel);
        print(response.data);
        return directionsModel;
      } else if (response.statusCode == 400) {
        print(response.data);
        showCustomSnackBar(
            isError: true, message: "لاتوجد سياره لهذا المستخدم");
      } else if (response.statusCode! >= 500) {
        showCustomSnackBar(isError: true, message: "توجد مشاكل فى السيرفر");
      }
    } catch (e) {}
  }

  bookPath({int? routeNumber, int? districtId}) async {
    try {
      final response = await dio!.post(AppConstants.bookPath,
          data: {"routeNumber": routeNumber, "districtId": districtId});
      if (response.statusCode == 200) {
        print(response.statusCode);

        Utility.displaySuccessAlert("تم حجز المسار بنجاح", Get.context!);
      } else {
        showCustomSnackBar(isError: true, message: "توجد مشكله فى السرفر");
      }
    } catch (e) {}
  }

  startMission() async {
    try {
      final response = await dio!.put(AppConstants.startMission);
      print(response.statusCode);
      if (response.statusCode == 200) {}
    } catch (e) {}
  }

  stopMission() async {
    try {
      final response = await dio!.put(AppConstants.endMission);
      if (response.statusCode == 200) {
        print(response.statusCode);

        Utility.displaySuccessAlert("تم ايقاف المسار مؤقتا", Get.context!);
      } else {
        showCustomSnackBar(isError: true, message: "توجد مشكله فى السرفر");
      }
    } catch (e) {}
  }

  continueMission() async {
    try {
      final response = await dio!.put(AppConstants.continueMission);
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  completeTask({int? districtId, int? routeId}) async {
    try {
      final response =
          await dio!.post("${AppConstants.completeTask}$districtId/$routeId");
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  end() async {
    try {
      final response = await dio!.put(AppConstants.end);
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  sendPoints({int? routeNumber, int? districtId, int? objectId}) async {
    try {
      final response =
          await dio!.post(AppConstants.addHistoryVehicleInfo, data: {
        "objectId": objectId,
        "districtId": districtId,
        "routNumber": routeNumber,
      });
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  addVehicleInfo({List<InfoModel>? data}) async {
    try {
      final response =
          await dio!.post(AppConstants.addVehicleInfos, data: data);
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }
  solveLocation({int? id, int? type}) async {
    try {
      final response = await dio!.post(AppConstants.solveLocation, data: {
        "id": id,
        "type": type,
      });
      if (response.statusCode == 200) {
        Get.snackbar('The problem has been resolved'.tr,
            "The Epicenter problem has been resolved",
            backgroundColor: Colors.white);
        print(response.statusCode);
      }
    } catch (e) {}
  }
}
