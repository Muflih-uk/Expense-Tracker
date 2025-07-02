class RegisterModel {
  String username;
  String email;
  String password;

  RegisterModel({
    required this.username,
    required this.email,
    required this.password
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json){
    return RegisterModel(
      username: json['username'], 
      email: json['email'], 
      password: json['password']
    );
  }

  Map<String,dynamic> toJson(){
    Map<String,dynamic> json = {
      'name': username,
      'email': email,
      'password': password
    };
    
    return json;
  }
}

class LoginModel {
  String email;
  String password;

  LoginModel({
    required this.email,
    required this.password,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
