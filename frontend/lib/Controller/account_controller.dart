import 'dart:convert';

import 'package:expense_tracker/Model/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountController {

  Future<void> saveToAccount(AccountModel account) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('account_data', jsonEncode(account.toJson()));
  }

  Future<String?> getAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final String? account = prefs.getString('account_data');
    return account;
  } 
}