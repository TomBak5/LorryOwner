import 'package:dio/dio.dart';
import 'package:movers_lorry_owner/Api_Provider/imageupload_api.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Api {
  final Dio _dio = Dio();
  Api() {
    _dio.options.baseUrl = basUrl;
    // Add the X-API-KEY header globally
    _dio.options.headers.addAll({
      'X-API-KEY': 'cscodetech',
      'Content-Type': 'application/json',
    });
    _dio.interceptors.add(
        PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        error: true
      ),
    );
  }
  Dio get sendRequest => _dio;
}
