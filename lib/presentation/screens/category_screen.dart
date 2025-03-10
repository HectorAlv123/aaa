import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/category_manager.dart';
import 'package:inventario_app/core/utils/fake_data_generator.dart'; // ✅ Importar FakeDataGenerator

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncCategories(); // ✅ Sincronizar categorías al abrir la pantalla
  }

  /// 📌 **Sincroniza las categorías de FakeDataGenerator con CategoryManager**
  void _syncCategories() {
    for (var category in FakeDataGenerator.categories) {
      if (!CategoryManager.instance.categories.contains(category)) {
        CategoryManager.instance.addCategory(category);
      }
    }
    setState(() {}); // ✅ Refrescar la UI
  }

  /// 📌 **Agregar Nueva Categoría**
  void _addCategory() {
    String newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty && !CategoryManager.instance.categories.contains(newCategory)) {
      setState(() {
        CategoryManager.instance.addCategory(newCategory);
        FakeDataGenerator.categories.add(newCategory); // ✅ También la agregamos a FakeDataGenerator
        _categoryController.clear();
      });
    }
  }

  /// 📌 **Eliminar Categoría**
  void _removeCategory(String category) {
    setState(() {
      CategoryManager.instance.removeCategory(category);
      FakeDataGenerator.categories.remove(category); // ✅ También la eliminamos de FakeDataGenerator
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryManager.instance.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Categorías"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📌 Campo para agregar nueva categoría
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: "Nueva categoría",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text("Agregar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 📌 Lista de categorías
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text("No hay categorías registradas."))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: Text(category),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeCategory(category),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
