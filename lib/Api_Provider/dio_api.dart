import 'package:dio/dio.dart';
import 'package:movers_lorry_owner/Api_Provider/imageupload_api.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Api {
  final Dio _dio = Dio();
  Api() {
    // Don't set a baseUrl here since we use different base URLs in different methods
    // _dio.options.baseUrl = basUrl;
    // Add the X-API-KEY header globally
    _dio.options.headers.addAll({
      'X-API-KEY': 'cscodetech',
      'Content-Type': 'application/json',
    });
    
    // Add timeout configuration
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          // Retry on timeout or connection errors
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            print('Network error: ${e.message}, retrying...');
            // You can implement retry logic here if needed
          }
          handler.next(e);
        },
      ),
    );
    
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
