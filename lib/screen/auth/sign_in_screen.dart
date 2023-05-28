import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracking_app/component/custom_button.dart';
import 'package:tracking_app/component/fixed_text_field.dart';
import 'package:tracking_app/screen/auth/controller/signin_controller.dart';
import 'package:tracking_app/screen/map_screen/map_screen.dart';
import 'package:tracking_app/util/dimensions.dart';
import 'package:tracking_app/util/images.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInController());
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FEFE),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Images.logo, width: Dimensions.width * 0.4),
                SizedBox(
                  height: Dimensions.height * 0.02,
                ),
                const Text(
                  " وزارة الشؤون البلدية والقروية   ",
                  style: TextStyle(
                    color: Color(0xff005133),
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "أمانة منطقة الرياض ",
                  style: TextStyle(
                    color: Color(0xff005133),
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: Dimensions.height * 0.04,
                ),
                Obx(() => FixedTextField(
                      errorLabel: controller.email.error,
                      function: (email) {
                        controller.changeUserName(email);
                      },
                      prefixIcon:
                          const Icon(Icons.email, color: Color(0xff008d36)),
                      label: "البريد الالكترونى".tr,
                    )),
                SizedBox(
                  height: Dimensions.height * 0.02,
                ),
                Obx(() => FixedTextField(
                      errorLabel: controller.password.error,
                      obSecure: controller.isSecure.value,
                      function: (password) {
                        controller.changePassword(password);
                      },
                      suffixIcon: IconButton(
                          onPressed: () {
                            controller.isSecure.value =
                                !controller.isSecure.value;
                          },
                          icon: Icon(
                              controller.isSecure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xff008d36))),
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xff008d36)),
                      label: "الرقم السرى".tr,
                    )),
                SizedBox(
                  height: Dimensions.height * 0.04,
                ),
                Obx(() => controller.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff008d36),
                        ),
                      )
                    : CustomButton(
                        color: const Color(0xff008d36).withOpacity(0.9),
                        onPressed: () {
                          controller.signIn();
                        },
                        width: Dimensions.width * 0.8,
                        radius: Dimensions.RADIUS_DEFAULT,
                        buttonText: "تسجيل الدخول".tr,
                      ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
