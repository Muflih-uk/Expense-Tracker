class CategoryModel {
  String title;

  CategoryModel({
    required this.title,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
    };
  }
}