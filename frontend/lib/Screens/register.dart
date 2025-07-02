import 'package:expense_tracker/Constants/app_color.dart';
import 'package:expense_tracker/Controller/auth_cotroller.dart';
import 'package:expense_tracker/Model/auth_model.dart';
import 'package:expense_tracker/Screens/Widgets/auth_widgets.dart';
import 'package:expense_tracker/Services/auth_service.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  State<Register> createState() => StateRegister(); 
}

class StateRegister extends State<Register>{


  // from key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final AuthController _controller = AuthController();

  // Service
  final AuthService _service = AuthService();

  void _submitUser() async{
    if(_formKey.currentState!.validate()){
      final newUser = RegisterModel(
        username: _usernameCtrl.text.trim(), 
        email: _emailCtrl.text.trim(), 
        password: _passwordCtrl.text.trim()
      );

      final token = await _service.registerUser(newUser);

      if (token != null) {
        _controller.setUserToken(token);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Register Successful!')),
        );
        Navigator.pushNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered Failed')),
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
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo and Name
                  AuthWidgets.logoName(),

                  // Username field
                  SizedBox(height: 60,),
                  AuthWidgets.textForm(
                    isUsername: true,
                    controller: _usernameCtrl,
                    icon: Icons.person_2_outlined, 
                    hint: "Username", 
                  ),

                  // Email Field
                  SizedBox(height: 20,),
                  AuthWidgets.textForm(
                    isEmail: true,
                    controller: _emailCtrl,
                    icon: Icons.email, 
                    hint: "Email Address", 
                  ),

                  // Password Field
                  SizedBox(height: 20,),
                  AuthWidgets.textForm(
                    controller: _passwordCtrl,
                    icon: Icons.lock, 
                    hint: "Password", 
                    obscure: true
                  ),

                  // Register Button
                  SizedBox(height: 20,),
                  AuthWidgets.authButton(
                    authType: "REGISTER",
                    onSubmit: _submitUser
                  )
                ],
              ),
            )
          )
        ),
      ),
    );
  }
}