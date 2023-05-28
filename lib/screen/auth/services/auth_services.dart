import 'package:get/get.dart';
import 'package:tracking_app/component/custom_snackbar.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/helper/dio_integration.dart';
import 'package:tracking_app/model/user_model.dart';
import 'package:tracking_app/screen/home_screen/home_screen.dart';
import 'package:tracking_app/util/app_constants.dart';

class AuthServices {
  final dio = DioUtilNew.dio;

  signIn({
    String? email,
    String? password,
  }) async {
    try {
      final response = await dio!.post(AppConstants.login, data: {
        "Email": email,
        "Password": password,
      });
      if (response.statusCode == 200) {
        UserModel userModel = UserModel.fromJson(response.data);
        CacheHelper.saveData(
            key: AppConstants.expireOn, value: userModel.data!.expiresOn);
        CacheHelper.saveData(
            key: AppConstants.role, value: userModel.data!.role);
        CacheHelper.saveData(
            key: AppConstants.token, value: userModel.data!.token);
        CacheHelper.saveData(
            key: AppConstants.name, value: userModel.data!.name);
        Get.offAll(() => const HomeScreen());
        DioUtilNew.setDioAgain();
      } else if (response.statusCode == 400) {
        showCustomSnackBar(
            message: "Error in Email Or Password", isError: true);
      }
    } catch (e) {
      print(e);
    }
  }
}
