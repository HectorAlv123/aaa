import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';

class AddGuideProductScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const AddGuideProductScreen({super.key, required this.products});

  @override
  _AddGuideProductScreenState createState() => _AddGuideProductScreenState();
}

class _AddGuideProductScreenState extends State<AddGuideProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final List<Map<String, dynamic>> _tempProducts = [];
  String? selectedCategory = "";

  @override
  void initState() {
    super.initState();
    _tempProducts.addAll(widget.products);
  }

  /// 🔹 Obtener productos existentes en el inventario
  List<String> get existingProducts => InventoryManager.instance.inventoryItems
      .map((item) => item.description)
      .toSet()
      .toList();

  void _addProduct() {
    if (_productNameController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
      setState(() {
        _tempProducts.add({
          "name": _productNameController.text.trim(),
          "quantity": int.tryParse(_quantityController.text) ?? 0,
          "category": selectedCategory!.isNotEmpty ? selectedCategory : "Sin Categoría",
        });
        _productNameController.clear();
        _quantityController.clear();
        _categoryController.clear();
        selectedCategory = "";
      });
    }
  }

  void _removeProduct(int index) {
    setState(() {
      _tempProducts.removeAt(index);
    });
  }

  void _saveProducts() {
    Navigator.pop(context, _tempProducts); // Devolver la lista a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Productos a la Guía")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return existingProducts.where((option) =>
                    option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _productNameController.text = selection;

                final existingProduct = InventoryManager.instance.inventoryItems.firstWhere(
                  (item) => item.description == selection,
                  orElse: () => InventoryItem(
                    id: "",
                    description: "",
                    guiaIngreso: "",
                    quantity: 0,
                    receiver: "",
                    receptionDateTime: DateTime.now(),
                    location: "",
                    category: "",
                  ),
                );

                setState(() {
                  selectedCategory = existingProduct.id.isNotEmpty ? existingProduct.category : "";
                });
              },
              fieldViewBuilder: (context, textEditingController, fieldFocusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(labelText: "Nombre del Producto"),
                );
              },
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: "Cantidad"),
              keyboardType: TextInputType.number,
            ),
            if (selectedCategory == "") // Si el producto no existe, pedir categoría
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Categoría"),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text("Añadir a la Lista"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lista de Productos",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tempProducts.length,
                itemBuilder: (context, index) {
                  final product = _tempProducts[index];
                  return Card(
                    child: ListTile(
                      title: Text(product["name"]),
                      subtitle: Text("Cantidad: ${product["quantity"]} | Categoría: ${product["category"]}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeProduct(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveProducts,
              child: const Text("Guardar Productos"),
            ),
          ],
        ),
      ),
    );
  }
}
