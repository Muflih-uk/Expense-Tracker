import 'package:expense_tracker/Screens/Widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'Widgets/add_widget.dart';

class AddPage extends StatelessWidget {

  void backPage(BuildContext context){
    Navigator.pushNamed(context, '/home');
  }

  void addIncome(BuildContext context){
    Navigator.pushNamed(context, '/add_income');
  }

  void addExpense(BuildContext context){
    Navigator.pushNamed(context, '/add_expense');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.topBar(
        context: context, 
        title: "Add", 
        leftArrow: backPage
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AddWidget.addDiv(
              context: context,
              typeOfTrans: "Income",
              addMove: addIncome
            ),
            SizedBox(height: 60,),
            AddWidget.addDiv(
              context: context,
              typeOfTrans: "Expense",
              addMove: addExpense
            )
          ],
        ),
      ),
    );
  }
}