import 'package:expense_tracker/Constants/app_color.dart';
import 'package:expense_tracker/Controller/auth_cotroller.dart';
import 'package:expense_tracker/Model/auth_model.dart';
import 'package:expense_tracker/Services/auth_service.dart';
import 'package:flutter/material.dart';

// Widgets
import 'Widgets/auth_widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _StateLogin();
}

class _StateLogin extends State<Login> {

  // form Key
  final fromKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final AuthController _controller = AuthController();

  // Service
  final AuthService _service = AuthService();

  // On Submit
  Future<void> _onSubmit() async{
    if(fromKey.currentState!.validate()){
      LoginModel user = LoginModel(
        email: _emailCtrl.text.trim(), 
        password: _passwordCtrl.text.trim()
      );

      final token = await _service.loginUser(user);
      

      if (token != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful!')),
        );
        _controller.setUserToken(token);
        Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Failed')),
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appPrimary,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: fromKey,
            child: Column(
              children: [
                // Logo with Name
                AuthWidgets.logoName(),

                // Username Form Field
                SizedBox(height: 50),
                AuthWidgets.textForm(
                  icon: Icons.person_2_outlined,
                  hint: "Email",
                  isEmail: true,
                  controller: _emailCtrl
                ),

                // Password Feld
                SizedBox(height: 20,),
                AuthWidgets.textForm(
                  controller: _passwordCtrl,
                  icon: Icons.lock, 
                  hint: 'Password', 
                  obscure: true
                ),

                // Login Button
                SizedBox(height: 20,),
                AuthWidgets.authButton(
                  authType: "LOGIN",
                  onSubmit: _onSubmit
                ),

                // Later Add the Forget Password

                // Register here
                SizedBox(height: 250,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 0,
                  children: [
                    Text(
                      "Don't have an account? "
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero
                      ),
                      onPressed: (){
                        Navigator.pushNamed(context, '/register');
                      }, 
                      child: Text(
                        "Register here",
                        style: TextStyle(
                          color: AppColor.appSecondary
                        ),
                      )
                    )
                  ],
                )
              ]
            ),
          )
        ), 
      ) 
    );
  }
}