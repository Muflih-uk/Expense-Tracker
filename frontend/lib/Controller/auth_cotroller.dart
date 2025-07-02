import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  
  Future<void> setUserToken(String token) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('tokenKey', token);
  }

  Future<String?> getUserToken() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString('tokenKey');
    if(token != null){
      return token;
    }
    return null;
  }
}