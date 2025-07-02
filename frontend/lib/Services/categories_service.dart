import 'package:dio/dio.dart';
import 'package:expense_tracker/Controller/auth_cotroller.dart';


class CategoriesService {
  // Controller
  final AuthController _controller = AuthController();

  

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
    )
  );

  Future<List<Map<String, dynamic>>> getCategories() async{
    final String? token = await _controller.getUserToken(); 
    try{
      Response response;
      response = await dio.get(
        '/categories/with_stats/?period=month/',
        options: Options(
          headers: {
            'Authorization': 'Token $token'
          }
        )
      );
      if (response.statusCode == 200 && response.data is List) {
        // Fix: convert List<dynamic> to List<Map<String, dynamic>>
        return (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    }
    on DioException catch(e) {
      print('❌ Dio Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}