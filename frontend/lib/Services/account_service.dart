import 'package:dio/dio.dart';
import 'package:expense_tracker/Controller/auth_cotroller.dart';
import 'package:expense_tracker/Model/account_model.dart';

class AccountService {
  
  // Controller
  final AuthController _controller = AuthController();

  

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
    )
  );

  Future<AccountModel> createAccount(String title) async{
    final String? token = await _controller.getUserToken();
    try{
      Response response;
      response = await dio.post(
        '/accounts/',
        data: {"title": title},
        options: Options(
          headers: {
            'Authorization': 'Token $token'
          }
        )
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AccountModel.fromJson(response.data);
      } else {
      throw Exception('Failed to create account');
      }
    }
    on DioException catch(e) {
      print('❌ Dio Error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to create account');
    }
  }
}