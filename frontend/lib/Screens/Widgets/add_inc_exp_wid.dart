import 'package:expense_tracker/Constants/app_color.dart';
import 'package:flutter/material.dart';

class AddIncExpWidget {
  static TextFormField fieldBox({
    required TextEditingController controller,
    required bool numKeyboard 
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numKeyboard ? TextInputType.number : TextInputType.name,
      validator: (value) {
        if(value!.isEmpty){
          return "Enter the Field";
        }
        return null;
      },
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColor.gradientColor,
            width: 2
          )
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColor.gradientColor,
            width: 2
          )
        )
      ),
    );
  }

  // Add Button
  static Padding addButton({
    required BuildContext context,
    required Function(BuildContext) onSubmit,
    required String typeTrans 
  }){
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextButton(
        onPressed: () => onSubmit(context),
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
              typeTrans,
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