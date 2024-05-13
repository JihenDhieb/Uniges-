import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log the request details
    final log = {
      'type': 'Request',
      'url': options.uri.toString(),
      'timestamp':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString(),
      'body': options.data,
    };

    final logs = GetStorage().read<List<dynamic>>('http_logs') ?? [];
    logs.add(log);

    GetStorage().write('http_logs', logs);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log the response details
    final log = {
      'type': 'Response',
      'statusCode': response.statusCode,
      'url': response.requestOptions.uri.toString(),
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'body': response.data,
    };

    final logs = GetStorage().read<List<dynamic>>('http_logs') ?? [];
    logs.add(log);

    GetStorage().write('http_logs', logs);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final log = {
      'type': 'Error',
      'statusCode': err.response?.statusCode,
      'url': err.requestOptions.uri.toString(),
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'body': err.response?.data, // Add the error response body to the log
    };

    final logs = GetStorage().read<List<dynamic>>('http_logs') ?? [];
    logs.add(log);

    GetStorage().write('http_logs', logs);
    handler.next(err);
  }
}
