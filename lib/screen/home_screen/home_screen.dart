import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/auth/sign_in_screen.dart';
import 'package:tracking_app/screen/main_screen/main_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/dimensions.dart';
import 'package:tracking_app/util/images.dart';
import 'package:tracking_app/util/styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              height: Dimensions.height * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const MainScreen());
                },
                child: Card(
                  shadowColor: Colors.grey,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          Images.roadMap,
                          height: Dimensions.height * 0.15,
                          width: Dimensions.width * 0.4,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                        width: Dimensions.width * 0.42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xff008d36).withOpacity(0.9),
                        ),
                        child: Center(
                          child: Text(
                            "المسارات اليوميه",
                            style: robotoRegular.copyWith(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
