import 'package:expense_tracker/Constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingWidgets {
  //Pages
  static PageViewModel pages({
    required String image,
    required String heading1,
    required String heading2,
    required String subHeading2
  }){
    return PageViewModel(
      titleWidget: Padding(
        padding: EdgeInsets.only(top: 60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg',height: 25,width: 25,),
            Text(
              "monex",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            )
          ]
        ),
      ),
      bodyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Image.asset(image),
          // Heading 1
          SizedBox(height: 30,),
          Text(
            heading1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
          SizedBox(height: 10,),
              
          //Heading 2
          Text(
            heading2,
            style: TextStyle(
              color: Colors.black54
            ),
          ),
          Text(
            subHeading2,
            style: TextStyle(
              color: Colors.black54
            ),
          )
        ],
      )
    );
  }

  // Footer Button
  static Widget bottomButton(BuildContext context,Function(BuildContext) onDone){
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextButton(
        onPressed: onDone(context),
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
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.center,
            child: Text(
              "LET'S GO",
              style: TextStyle(color: AppColor.appPrimary),
            ),
          ),
        ),
      ),
    );
  } 


}