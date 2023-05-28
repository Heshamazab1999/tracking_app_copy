import 'package:get/get.dart';
import 'package:tracking_app/component/custom_snackbar.dart';
import 'package:tracking_app/controller/base_controller.dart';
import 'package:tracking_app/model/valid_model.dart';
import 'package:tracking_app/screen/auth/services/auth_services.dart';

class SignInController extends BaseController {
  final services = AuthServices();
  final isSecure = false.obs;
  final _email = Valid().obs;
  final _password = Valid().obs;
  final _loading = false.obs;

  Valid get email => _email.value;

  Valid get password => _password.value;

  bool get loading => _loading.value;

  changeUserName(String email) {
    if (email.trim().length < 6) {
      _email.value = Valid(error: "تأكد من ادخال البريد بشكل صحيح".tr);
    } else {
      _email.value = Valid(value: email);
    }
  }

  changePassword(String password) {
    if (password.trim().length < 6) {
      _password.value = Valid(error: "تأكد من ادخال الرقم السرى بشكل صحيح".tr);
    } else {
      _password.value = Valid(value: password);
    }
  }

  signIn() async {
    try {
      if ((_password.value.isValid() && _email.value.isValid())) {
        _loading.value = true;
        await services.signIn(
          email: _email.value.value,
          password: _password.value.value,
        );
        _loading.value = false;
      } else {
        _loading.value = false;
        showCustomSnackBar(
            message: "ensure_that_the_values_entered_correctly".tr,
            isError: true);
      }
    } catch (e) {
      _loading.value = false;
    }
  }
}
