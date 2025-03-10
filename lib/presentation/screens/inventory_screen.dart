// lib/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_app/data/models/inventory_item.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/domain/managers/category_manager.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final Uuid uuid = const Uuid();

  // Variable para almacenar el producto ingresado (ya sea escrito o seleccionado)
  String productName = "";
  // Controlador para la cantidad
  final TextEditingController quantityController = TextEditingController();

  // Variables para la categoría
  String selectedCategory = 'Sin categoría';
  List<String> catOptions = [];

  @override
  void initState() {
    super.initState();
    catOptions = CategoryManager.instance.categories.isNotEmpty
        ? CategoryManager.instance.categories
        : ['Sin categoría'];
    selectedCategory = catOptions.first;
  }

  // Función para agregar un producto al inventario
  void _addProduct() async {
    // Lista de productos existentes para sugerencias
    List<String> existingProducts = InventoryManager.instance.inventoryItems
        .map((item) => item.description)
        .toSet()
        .toList();

    // Reinicia los valores
    productName = "";
    quantityController.clear();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            TextEditingController productController =
                TextEditingController(text: productName);

            return AlertDialog(
              title: const Text("Agregar producto al inventario"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Autocomplete para sugerir productos existentes
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return existingProducts.where((option) => option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) {
                      setStateDialog(() {
                        productName = selection;
                        productController.text = selection;
                      });
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onEditingComplete) {
                      textEditingController.addListener(() {
                        setStateDialog(() {
                          productName = textEditingController.text;
                        });
                      });

                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration:
                            const InputDecoration(labelText: "Producto"),
                      );
                    },
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: "Cantidad"),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: catOptions.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        if (val != null) {
                          selectedCategory = val;
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: "Categoría"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String finalProduct = productName.trim();
                    final int quantity =
                        int.tryParse(quantityController.text.trim()) ?? 0;
                    
                    if (finalProduct.isEmpty || quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Datos inválidos")),
                      );
                      return;
                    }

                    final newItem = InventoryItem(
                      id: uuid.v4(),
                      description: finalProduct,
                      guiaIngreso: null,
                      quantity: quantity,
                      receiver: 'Inventario',
                      receptionDateTime: DateTime.now(),
                      location: 'Almacén',
                      category: selectedCategory,
                    );

                    // Agregar el producto y actualizar la UI
                    setState(() {
                      InventoryManager.instance.inventoryItems.add(newItem);
                    });

                    Navigator.of(context).pop();
                  },
                  child: const Text("Agregar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItems = InventoryManager.instance.inventoryItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario"),
      ),
      body: ListView.builder(
        itemCount: inventoryItems.length,
        itemBuilder: (context, index) {
          final item = inventoryItems[index];
          return ListTile(
            title: Text(item.description),
            subtitle:
                Text("Cantidad: ${item.quantity} - Categoría: ${item.category}"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
