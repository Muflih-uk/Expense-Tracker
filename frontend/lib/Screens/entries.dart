import 'package:expense_tracker/Screens/Widgets/app_widgets.dart';
import 'package:flutter/material.dart';

class Entries extends StatelessWidget{

  void backMove(BuildContext context){
    Navigator.pushNamed(context, '/home');
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppWidgets.topBar(
        context: context, 
        title: "Entries", 
        leftArrow: backMove
      ),
    );
  }
}