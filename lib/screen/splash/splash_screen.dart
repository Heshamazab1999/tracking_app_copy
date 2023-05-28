import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/auth/sign_in_screen.dart';
import 'package:tracking_app/screen/home_screen/home_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  late AnimationController _lottieAnimation;
  var expanded = false;
  final double _bigFontSize = kIsWeb ? 234 : 30;
  final transitionDuration = const Duration(seconds: 1);

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  int diffrenceBetweenExpireNow() {
    if (CacheHelper.getData(key: AppConstants.expireOn) != null) {
      DateTime expireDate =
          DateTime.parse(CacheHelper.getData(key: AppConstants.expireOn));
      DateTime now = DateTime.now();
      int diff = expireDate.difference(now).inHours;
      return diff;
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
    _lottieAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    Future.delayed(const Duration(seconds: 1))
        .then((value0) => setState(() => expanded = true))
        .then((value1) => const Duration(seconds: 1))
        .then(
          (value2) => Future.delayed(const Duration(seconds: 1)).then(
            (value3) => _lottieAnimation.forward().then((value4) {
              if (CacheHelper.getData(key: AppConstants.token) == null) {
                // Get.offAll(const MapScreen());
                Get.offAll(const SignInScreen());
              } else if (diffrenceBetweenExpireNow() < 1) {
                Get.offAll(const SignInScreen());
              } else {
                Get.offAll(const HomeScreen());
              }
            }),
          ),
        );
    // Future.delayed(const Duration(seconds: 5), () async {
    //   String time = await CacheHelper.getData(key: AppConstants.expireOn) ?? "";
    //   String token = await CacheHelper.getData(key: AppConstants.token) ?? "";
    //   print(token);
    //   print(time);
    //   print("time");
    //   if (time.isEmpty) {
    //     // Get.toNamed(AppRoute.signIn);
    //   } else {
    //     var output = DateFormat('MMMM d y , hh:mm a');
    //     var input =
    //         DateTime.parse(CacheHelper.getData(key: AppConstants.expireOn));
    //     print(output.format(input));
    //     final date2 = DateTime.now();
    //     final difference = input.difference(date2).inHours;
    //     print(difference);
    //     if (difference > 0) {
    //       // Get.toNamed(AppRoute.homeScreen);
    //       DioUtilNew.setDioAgain();
    //     } else if (difference <= 0) {
    //       CacheHelper.removeData(key: AppConstants.token);
    //       CacheHelper.removeData(key: AppConstants.expireOn);
    //       // Get.toNamed(AppRoute.signIn);
    //       DioUtilNew.setDioAgain();
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        key: _globalKey,
        body: Container(
          width: double.infinity,
          color: const Color(0xff005133),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedCrossFade(
                firstCurve: Curves.fastOutSlowIn,
                crossFadeState: !expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: transitionDuration,
                firstChild: Container(),
                secondChild: Image.asset(
                  Images.logo,
                  width: 150,
                  height: 150,
                ),
                alignment: Alignment.centerLeft,
                sizeCurve: Curves.easeInOut,
              ),
              AnimatedDefaultTextStyle(
                duration: transitionDuration,
                curve: Curves.fastOutSlowIn,
                style: TextStyle(
                  color: const Color(0xFFffffff),
                  fontSize: expanded ? _bigFontSize : 45,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
                child: const Text(
                  "المملكة العربية السعودية",
                  textAlign: TextAlign.center,
                ),
              ),
              AnimatedCrossFade(
                firstCurve: Curves.fastOutSlowIn,
                crossFadeState: !expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: transitionDuration,
                firstChild: Container(),
                secondChild: _logoRemainder(),
                alignment: Alignment.centerLeft,
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        ));
  }

  Widget _logoRemainder() {
    return Column(
      children: const [
        Text(
          " وزارة الشؤون البلدية والقروية   ",
          style: TextStyle(
            color: Color(0xFFffffff),
            fontSize: 25,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "أمانة منطقة الرياض ",
          style: TextStyle(
            color: Color(0xFFffffff),
            fontSize: 25,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
}
