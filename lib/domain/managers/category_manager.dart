// lib/managers/category_manager.dart
class CategoryManager {
  static final CategoryManager instance = CategoryManager._internal();
  CategoryManager._internal();

  final List<String> _categories = [];

  List<String> get categories => _categories;

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
    }
  }

  // Método para limpiar las categorías
  void clearData() {
    _categories.clear();
    print("Datos de categorías limpiados");
  }

  void removeCategory(String category) {
    _categories.remove(category);
  }
}
