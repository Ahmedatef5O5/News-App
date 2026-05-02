import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Single Dio instance shared across the app.
/// Handles base config, auth header, logging, and retry.

class DioClient {
  // Singleton Pattern

  DioClient._();
  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;
  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Authorization': 'Bearer ${AppConstants.apiKey}',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Logging in debug mode
    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => debugPrintDio(obj.toString()),
        ),
      );
      return true;
    }());

    return dio;
  }

  void debugPrintDio(String message) {
    debugPrint('[DioClient] $message');
  }
}
