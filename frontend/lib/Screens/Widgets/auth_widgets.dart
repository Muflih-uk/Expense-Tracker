import 'package:expense_tracker/Constants/app_color.dart';
import 'package:flutter/material.dart';

class AuthWidgets {

  // Logo and name
  static Column logoName(){
    return Column(
      children: [
        SizedBox(height: 50,),
        Image.asset(
          'assets/images/logo.jpg',
          height: 100,
          width: 100,
        ),
        Text(
          "monex",
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }

  // TextForm Field 
  static TextFormField textForm({ 
    required TextEditingController controller,
    required IconData icon, 
    required String hint, 
    bool obscure = false,
    bool isEmail = false,
    bool isUsername = false
    }){
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Colors.black,
      validator: (value) {
        if (isUsername) {
          if (value == null || value.isEmpty) return 'Enter Username';
          return null;
        } else if (isEmail) {
          if (value == null || value.isEmpty) return 'Enter email';
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) return 'Enter valid email';
          return null;
        } else {
          if (value == null || value.isEmpty) return 'Enter the Password';
          if (value.length < 6) return 'Password must be at least 6 characters';
          return null;
        }
      },
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 1,
            color: Colors.black
          )
        ),
        prefixIcon: Icon(icon,color: Colors.black,size: 30,),
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColor.placeHolderColor
        ),
        filled: true,
        fillColor: AppColor.textFieldFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColor.placeHolderColor,
            width: 1
          )
        )
      ),
    );
  }

  // Auth Button
  static Widget authButton({
    required String authType,
    required VoidCallback onSubmit
  }){
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextButton(
        onPressed: onSubmit,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, 
          backgroundColor: Colors.transparent, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.gradientColor, AppColor.appSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              authType,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.appPrimary
              ),
            ),
          ),
        ),
      ),
    );
  }

  
}