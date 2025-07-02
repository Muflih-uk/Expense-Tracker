import 'package:expense_tracker/Constants/app_color.dart';
import 'package:expense_tracker/Model/account_model.dart';
import 'package:flutter/material.dart';

class HomeWidgets{
  static Container topBar({
    required AccountModel? account,
    required BuildContext context,
    required Function(BuildContext) addAccount
  }){
    return Container(
      padding: EdgeInsets.only(left: 15,bottom: 15,top:26),
      height: 80,
      decoration: BoxDecoration(
        color: AppColor.appPrimary
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 200,
        children: [
          Text(
            "Overview",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black
            ),
          ),
          (account != null) ?
            IconButton(
              onPressed: () => addAccount(context), 
              icon: Icon(Icons.person,color: Colors.black,size: 38,)
            ) :
            IconButton(
              onPressed: () => addAccount(context), 
              icon: Icon(Icons.person_add,color: Colors.black,size: 38,)
            )
          
        ],
      ),
    );
  }

  // Total Expense and Total Salary
  static GestureDetector totalDiv({
    required String typeOfTrans,
    required int cash
  }){
    return GestureDetector(
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
        height: 150,
        child: Padding(
          padding: EdgeInsets.only(top: 20,left: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.account_balance_wallet_outlined,color: AppColor.appPrimary,size: 30,),
              SizedBox(height: 5,),
              Text(
                "Total $typeOfTrans",
                style: TextStyle(
                  color: AppColor.appPrimary,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 0,
                children: [
                  Icon(Icons.currency_rupee,color: AppColor.appPrimary,size: 23,),
                  Text(
                    "$cash",
                    style: TextStyle(
                      color: AppColor.appPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Add the Expense and Salary
  static Container addTrans(){
    return Container(
      height: 446,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        color: AppColor.appPrimary
      ),
      child: Text("Soon")
    );
  }

}