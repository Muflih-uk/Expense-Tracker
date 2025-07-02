import 'package:expense_tracker/Constants/app_color.dart';
import 'package:expense_tracker/Provider/account_provider.dart';
import 'package:expense_tracker/Screens/Widgets/app_widgets.dart';
import 'package:expense_tracker/Screens/Widgets/auth_widgets.dart';
import 'package:expense_tracker/Services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget{
  @override
  State<Account> createState() => StateAccount();
}
class StateAccount extends State<Account> {

  // Controllers
  final TextEditingController _nameCtrl = TextEditingController();

  void backMove(BuildContext context){
    Navigator.pushNamed(context, '/home');
  }



  
  final _formKey = GlobalKey<FormState>();
  final AccountService _service = AccountService();


  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    void onSubmit() async{
      if (_formKey.currentState!.validate()) {
        try {
          final newAccount = await _service.createAccount(
            _nameCtrl.text.trim()
          );
          accountProvider.setAccount(newAccount);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    return Scaffold(
      //topBar
      appBar: AppWidgets.topBar(
        context: context, 
        title: 'Account', 
        leftArrow: backMove
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: account == null ?
          Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hint: Text("Enter name"),
                    border: OutlineInputBorder()
                  ),
                  validator: (value) => 
                    value == null || value.isEmpty ? 'Required' : null,
                )
              ),

              // Submit Button
              const SizedBox(height: 30,),
              AuthWidgets.authButton(
                authType: "SUBMIT", 
                onSubmit: onSubmit
              )

            ],
          ) : Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 30,
                    spreadRadius: 8
                  )
                ],
                borderRadius: BorderRadius.circular(20),
                color: AppColor.appPrimary
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Account Name: ${account.title}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 30,),
                  Text(
                    'Balance: ${account.currentBalance}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  //Text('User ID: ${account.user}'),
                ],
              ),
            ),
          )
      ),
    );
  }
}