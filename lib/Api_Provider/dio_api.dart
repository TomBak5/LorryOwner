import 'package:dio/dio.dart';
import 'package:movers_lorry_owner/Api_Provider/imageupload_api.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Api {
  final Dio _dio = Dio();
  Api() {
    _dio.options.baseUrl = basUrl;
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
