import 'package:dio/dio.dart';
import 'package:expense_tracker/Controller/auth_cotroller.dart';
import 'package:expense_tracker/Model/transaction_model.dart';
import 'dart:convert';

class TranscationService {
  // Controller
  final AuthController _controller = AuthController();

  

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
    )
  );

  Future<bool> postTransaction(TransactionModel transModel) async {
    final String? token = await _controller.getUserToken();

    if (token == null) {
      print('❌ Token is null. Cannot post transaction.');
      return false;
    }

    try {
      print("Hello");
      Response response = await dio.post(
        '/transactions/',
        data: jsonEncode(transModel.toJson()),
        options: Options(
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json'
          }
        ),
      );
      print("Status: ${response.statusCode}");

      print("✅ Response : ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  } on DioException catch (e) {
    print('❌ Dio Error Transaction: ${e.message}');
    print('❌ Dio Error Response: ${e.response}');
    print('❌ Dio Error Data: ${e.response?.data}');
    print('❌ Dio Error Status: ${e.response?.statusCode}');
    return false;
  }
}

}