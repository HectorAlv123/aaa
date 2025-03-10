// lib/presentation/screens/select_products_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';

class SelectProductsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialProducts;

  const SelectProductsScreen({Key? key, required this.initialProducts}) : super(key: key);

  @override
  _SelectProductsScreenState createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  List<Map<String, dynamic>> _selectedProducts = [];
  List<InventoryItem> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedProducts = List.from(widget.initialProducts);
    _filteredProducts = List.from(InventoryManager.instance.inventoryItems);

    for (var item in _filteredProducts) {
      _quantityControllers[item.id] = TextEditingController(text: "0");
    }
  }

  void _updateQuantity(String productId, String value) {
    int quantity = int.tryParse(value) ?? 0;
    if (quantity < 0) quantity = 0;

    setState(() {
      final existingProduct = _selectedProducts.firstWhere(
        (p) => p["id"] == productId,
        orElse: () => {},
      );

      if (existingProduct.isNotEmpty) {
        existingProduct["quantity"] = quantity;
      } else {
        _selectedProducts.add({
          "id": productId,
          "description": _filteredProducts.firstWhere((p) => p.id == productId).description,
          "location": _filteredProducts.firstWhere((p) => p.id == productId).location,
          "category": _filteredProducts.firstWhere((p) => p.id == productId).category, // ✅ Muestra la categoría
          "quantity": quantity,
        });
      }

      _quantityControllers[productId]!.text = quantity.toString();
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = InventoryManager.instance.inventoryItems.where((item) {
        return item.description.toLowerCase().contains(query.toLowerCase()) ||
               item.location.toLowerCase().contains(query.toLowerCase()) ||
               item.category.toLowerCase().contains(query.toLowerCase()); // ✅ Permite filtrar por categoría
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar Productos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Buscar producto",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final item = _filteredProducts[index];
                final maxQuantity = item.quantity;
                final controller = _quantityControllers[item.id]!;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text("${item.description}"),
                    subtitle: Text("📍 Ubicación: ${item.location}  | 🏷 Categoría: ${item.category} | 🔢 Disponible: $maxQuantity"),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "0",
                        ),
                        onChanged: (value) {
                          if (int.tryParse(value) != null && int.parse(value) <= maxQuantity) {
                            _updateQuantity(item.id, value);
                          } else {
                            controller.text = "0";
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedProducts);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
