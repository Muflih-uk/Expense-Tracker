import 'package:flutter/material.dart';
import 'package:expense_tracker/Services/categories_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoriesService _service = CategoriesService();

  List<Map<String, dynamic>>? _categories;
  int? _selectedId;
  bool _isLoading = true;

  List<Map<String, dynamic>> get categories => _categories ?? [];
  int? get selectedId => _selectedId;
  bool get isLoading => _isLoading;

  Future<void> fetchCategory() async {
    _isLoading = true;
    notifyListeners();

    print("Fetching categories...");

    try {
      final data = await _service.getCategories();
      print("Raw data: $data");
      _categories = data;
    } catch (e) {
      print("Error fetching categories: $e");
      _categories = [];
    }

    _isLoading = false;
    notifyListeners();
  }


  void selectCategory(int id) {
    _selectedId = id;
    notifyListeners();
  }
}
