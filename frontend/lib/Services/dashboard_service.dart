import 'package:dio/dio.dart';
import 'package:expense_tracker/Controller/auth_cotroller.dart';


class DashboardService {
  
  // Controller
  final AuthController _controller = AuthController();

  

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
    )
  );

  Future<Map<String, dynamic>?> getDashboard() async {
  final String? token = await _controller.getUserToken();

  if (token == null) {
    print('❌ No auth token found');
    return null;
  }

  try {
    final response = await dio.get<Map<String, dynamic>>(
      '/dashboard/?period=month',
      options: Options(
        headers: {
          'Authorization': 'Token $token',
        },
      ),
    );

    final data = response.data;

    if (data == null) {
      print('❌ Empty response data');
      return null;
    }
    return data;
  } on DioException catch (e) {
    print('❌ Dio Error: ${e.response?.data ?? e.message}');
    return null;
  } catch (e) {
    print('❌ Unknown Error: $e');
    return null;
  }
}

}