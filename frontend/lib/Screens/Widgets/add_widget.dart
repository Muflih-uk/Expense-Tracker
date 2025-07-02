import 'package:flutter/material.dart';
import 'package:expense_tracker/Constants/app_color.dart';

class AddWidget {
  static GestureDetector addDiv({
    required BuildContext context,
    required String typeOfTrans,
    required Function(BuildContext) addMove
  }){
    return GestureDetector(
      onTap: () => addMove.call(context),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 1),
              blurRadius: 20,
              spreadRadius: 5,   
            )
          ],
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [AppColor.gradientColor,AppColor.appSecondary],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft
          )
        ),
        width: 120,
        height: 120,
        child: Padding(
          padding: EdgeInsets.only(top: 20,left: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.account_balance_wallet_outlined,color: AppColor.appPrimary,size: 30,),
              SizedBox(height: 5,),
              Text(
                "Add $typeOfTrans",
                style: TextStyle(
                  color: AppColor.appPrimary,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}