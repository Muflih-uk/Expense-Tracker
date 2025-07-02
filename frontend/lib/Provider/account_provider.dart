import 'dart:convert';

import 'package:expense_tracker/Controller/account_controller.dart';
import 'package:expense_tracker/Model/account_model.dart';
import 'package:flutter/foundation.dart';

class AccountProvider extends ChangeNotifier {
  
  // Controller
  final AccountController _accountCtrl = AccountController();

  int? _accountId;
  int? get accountId => _accountId;
  AccountModel? _account;
  AccountModel? get account => _account;

  void setAccount(AccountModel account){
    _account = account;
    _accountCtrl.saveToAccount(account);
    _accountId = account.id;
    notifyListeners();
  }

  Future<void> loadAccount() async {
    final String? account = await _accountCtrl.getAccount();
    if (account != null) {
      _account = AccountModel.fromJson(jsonDecode(account));
      _accountId = _account!.id; 
      notifyListeners();
    }
  }



}