

import 'package:flutter/material.dart';
import 'package:expense_tracker/Constants/app_color.dart';

// Plus Button
class AppWidgets {
  static GestureDetector plusButton({
    required BuildContext context,
    required Function(BuildContext) onTapHandler
  }){
    return GestureDetector(
      onTap: () => onTapHandler.call(context),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColor.gradientColor, AppColor.appSecondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  // Top Bar
  static AppBar topBar({
    required BuildContext context,
    required String title,
    required Function(BuildContext) leftArrow
  }){
    return AppBar(
      actionsPadding: EdgeInsets.only(),
      backgroundColor: AppColor.appPrimary,
      leading: IconButton(
        onPressed: () => leftArrow(context),
        icon: Icon(
          Icons.chevron_left_sharp,
          color: Colors.black,
          size: 40,
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}