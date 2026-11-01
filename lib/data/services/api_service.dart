import 'dart:convert';

import 'package:dio/dio.dart';

/// A failure the UI can show verbatim. Every Dio error is translated into one of these so no screen ever has to know what a [DioException] is.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'The request timed out. Check your connection and try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Reconnect and try again.',
        );
      case DioExceptionType.badResponse:
        final int? code = error.response?.statusCode;
        return ApiException(
          'We could not reach the server'
          '${code == null ? '' : ' (error $code)'}. Please try again shortly.',
        );
      case DioExceptionType.cancel:
        return const ApiException('Request cancelled.');
      // badCertificate, unknown, transformTimeout, and anything Dio adds in
      // a future release.
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }
}

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static const String baseUrl = 'https://dummyjson.com';

  /// Signed-in user's profile, hosted as a JSON document.
  static const String userProfileUrl =
      'https://gist.githubusercontent.com/saladel/'
      'bef05957dfee51902b532330a5aa4b5d/raw/user.json';

  /// savings products url.
  static const String productsUrl =
      'https://gist.githubusercontent.com/saladel/'
      'bb33f504fc93ff66b9191b0f0ea3fa3f/raw/6c099b552e6e84f51a17386505447c5b05fe5e94/products.json';

  /// savings plan url
  static const String savingsPlansUrl =
      'https://gist.githubusercontent.com/saladel/'
      'b396eb64da17c08bd0262d8099848e9c/raw/1f67e5ababcba36d674bbc3b4be46ec235957d23/savings-plan.json';

  /// endpoint for creating a plan. a gist can only serve GET, so this points at a Beeceptor endpoint.
  static const String createSavingsPlanUrl =
      'https://koins-mfb-assessment.free.beeceptor.com/create-savings-plan';

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: <String, String>{'Accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );
  }

  /// `GET /posts?limit=n`
  Future<List<Map<String, dynamic>>> fetchInsights({int limit = 6}) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(
            '/posts',
            queryParameters: <String, dynamic>{'limit': limit},
          );

      final List<dynamic> posts =
          response.data?['posts'] as List<dynamic>? ?? const <dynamic>[];

      return posts.whereType<Map<String, dynamic>>().toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } catch (_) {
      throw const ApiException(
        'We could not load insights right now. Please try again.',
      );
    }
  }

  /// `GET` the signed-in user's profile.
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final Object? decoded = await _getJson(userProfileUrl, label: 'profile');

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Your profile was not in the expected format.');
    }
    return decoded;
  }

  /// `GET` the savings product catalogue.
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final Object? decoded = await _getJson(
      productsUrl,
      label: 'savings products',
    );

    if (decoded is! List<dynamic>) {
      throw const ApiException(
        'The savings products were not in the expected format.',
      );
    }
    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  /// `GET` the starter savings plans used to seed a fresh install.
  Future<List<Map<String, dynamic>>> fetchSavingsPlans() async {
    final Object? decoded = await _getJson(
      savingsPlansUrl,
      label: 'savings plans',
    );

    if (decoded is! List<dynamic>) {
      throw const ApiException(
        'The savings plans were not in the expected format.',
      );
    }
    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  /// `POST` a newly created savings plan.
  ///
  /// Only the status code matters. The mock endpoint response body is not part of the contract.
  Future<void> createSavingsPlan(Map<String, dynamic> body) async {
    try {
      await _dio.post<dynamic>(
        createSavingsPlanUrl,
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } catch (_) {
      throw const ApiException(
        'We could not reach the server to save your plan.',
      );
    }
  }

  /// Shared fetch-and-decode used by the hosted JSON endpoints.
  Future<Object?> _getJson(String url, {required String label}) async {
    try {
      final Response<String> response = await _dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      final String body = response.data?.trim() ?? '';
      if (body.isEmpty) {
        throw ApiException('The $label response came back empty.');
      }

      return jsonDecode(body);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException('The $label response was not valid JSON.');
    } catch (_) {
      throw ApiException('We could not load the $label. Please try again.');
    }
  }
}
