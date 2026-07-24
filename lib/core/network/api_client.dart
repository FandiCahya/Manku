import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = _initDio();
  /// Called when the session expires and token refresh fails.
  /// Register this in main.dart / your root widget to trigger logout.
  static void Function()? onUnauthorized;

  static Dio get dio => _dio;

  static Dio _initDio() {
    final baseOptions = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final dioInstance = Dio(baseOptions);

    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = ApiConfig.baseUrl;

          // Hanya endpoint publik (login/register/OTP) yang tidak perlu token.
          // Endpoint profile, change-password, toggle-2fa tetap butuh token.
          const publicPaths = [
            '/auth/login/',
            '/auth/register/',
            '/auth/verify-otp/',
            '/auth/google-login/',
            '/auth/token/refresh/',
          ];
          final isPublic = publicPaths.any((p) => options.path.contains(p));
          if (!isPublic) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          const publicPaths = [
            '/auth/login/',
            '/auth/register/',
            '/auth/verify-otp/',
            '/auth/google-login/',
            '/auth/token/refresh/',
          ];
          final isPublicPath = publicPaths.any(
            (p) => error.requestOptions.path.contains(p),
          );
          if (error.response?.statusCode == 401 && !isPublicPath) {
            final prefs = await SharedPreferences.getInstance();
            final refreshToken = prefs.getString('refresh_token');

            if (refreshToken != null) {
              try {
                final refreshResponse = await Dio().post<Map<String, dynamic>>(
                  '${ApiConfig.baseUrl}/api/auth/token/refresh/',
                  data: {'refresh': refreshToken},
                );

                if (refreshResponse.statusCode == 200 &&
                    refreshResponse.data != null) {
                  final newAccessToken = refreshResponse.data!['access'] as String;
                  await prefs.setString('access_token', newAccessToken);

                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccessToken';

                  final response = await dioInstance.fetch<dynamic>(options);
                  return handler.resolve(response);
                }
              } catch (_) {
                // Refresh token invalid/expired — clear entire session
                await prefs.remove('access_token');
                await prefs.remove('refresh_token');
                await prefs.remove('user_name');
                await prefs.remove('user_email');
                await prefs.remove('user_photo');
                onUnauthorized?.call();
              }
            } else {
              onUnauthorized?.call();
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dioInstance;
  }
}
