import 'package:dio/dio.dart';
import 'package:expense_tracker/Model/auth_model.dart';


class AuthService {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      headers: {
        'Content-Type': 'application/json',
      },
    )
  );

  // Register the User
  Future<String?> registerUser(RegisterModel user) async{
    try{
      Response response;
      response = await dio.post(
        '/auth/signup/',
        data: user.toJson()
      );
      final token = response.data['token'];
      return token;
    } 
    on DioException catch(e) {
      print('❌ Dio Error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // Login with User
  Future<String?> loginUser(LoginModel user) async {
    try {
      Response response = await dio.post(
        '/auth/signin/', 
        data: user.toJson(),
      );
      
      if (response.statusCode == 200) {
        final token = response.data['token'];
        return token;
      } else {
        return null;
      }
    } on DioException catch (e) {
      print('❌ Login error: ${e.response?.data ?? e.message}');
      return null;
    }
  } 
}