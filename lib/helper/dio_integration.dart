import 'package:dio/dio.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/helper/dio_interceptors.dart';
import 'package:tracking_app/util/app_constants.dart';

class DioUtilNew {
  static DioUtilNew? _instance;
  static Dio? _dio;

  static DioUtilNew? getInstance() {
    if (_instance == null) {
      _dio = Dio(_getOptions());
      _dio!.interceptors.add(CustomInterceptors());
    }
    return _instance;
  }

  static Dio? get dio => _dio;

  static void setDioAgain() {
    _dio = Dio(_getOptions());
  }

  static BaseOptions _getOptions() {
    BaseOptions options = BaseOptions(
      followRedirects: false,
      validateStatus: (status) => status! <= 500,
    );

    options.connectTimeout = const Duration(seconds: 100 * 1000); //10 sec
    options.receiveTimeout = const Duration(seconds: 100 * 1000); //20 sec
    options.baseUrl = AppConstants.baseUrl;
    options.headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${CacheHelper.getData(key: AppConstants.token)}"
    };
    options.queryParameters = {};

    return options;
  }
}
