import 'package:flutter/material.dart';
import 'package:expense_tracker/Services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier{

  final DashboardService _service = DashboardService();

  Map<String, dynamic>? _data;
  Map<String, dynamic>? get data => _data;

  void fetchDashboardData() async{
    _data = await _service.getDashboard();
    notifyListeners();
  }
}