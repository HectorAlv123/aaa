import 'package:flutter/material.dart';
import 'package:inventario_app/core/utils/fake_data_generator.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/domain/managers/category_manager.dart';
import 'package:inventario_app/domain/managers/provider_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _newProviderController = TextEditingController();

  String? _selectedCategory;
  String? _selectedProvider;
  String? _selectedLocation;
  List<String> categories = [];
  List<String> providers = [];
  List<String> existingProducts = [];
  final List<String> locations = ["Galpón Azul", "Galpón Verde", "Bodega de EPPs"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    categories = List.from(FakeDataGenerator.categories);
    providers = List.from(FakeDataGenerator.providers);
    existingProducts = InventoryManager.instance.inventoryItems.map((item) => item.description).toSet().toList();

    if (_selectedLocation == null) {
      _selectedLocation = locations.first; // ✅ Por defecto, primera ubicación
    }
  }

  void _saveProduct() {
    final description = _descriptionController.text.trim();
    final quantityText = _quantityController.text.trim();

    if (description.isEmpty || quantityText.isEmpty || _selectedCategory == null || _selectedProvider == null || _selectedLocation == null) {
      _showSnackbar("Todos los campos son obligatorios", isError: true);
      return;
    }

    final quantity = int.tryParse(quantityText) ?? 0;
    if (quantity <= 0) {
      _showSnackbar("La cantidad debe ser mayor a 0", isError: true);
      return;
    }

    final inventory = InventoryManager.instance;
    final newProduct = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      guiaIngreso: null,
      quantity: quantity,
      receiver: "N/A",
      receptionDateTime: DateTime.now(),
      location: _selectedLocation!,
      category: _selectedCategory!,
    );

    inventory.addProduct(newProduct, supplier: _selectedProvider!);

    _showSnackbar("Producto agregado correctamente");
    Navigator.pop(context, true);
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Nueva Categoría"),
          content: TextField(
            controller: _newCategoryController,
            decoration: const InputDecoration(labelText: "Nombre de la Categoría"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            TextButton(
              onPressed: () {
                final newCategory = _newCategoryController.text.trim();
                if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                  setState(() {
                    categories.add(newCategory);
                    _selectedCategory = newCategory;
                    CategoryManager.instance.addCategory(newCategory);
                  });
                }
                _newCategoryController.clear();
                Navigator.pop(context);
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  void _showAddProviderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Nuevo Proveedor"),
          content: TextField(
            controller: _newProviderController,
            decoration: const InputDecoration(labelText: "Nombre del Proveedor"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            TextButton(
              onPressed: () {
                final newProvider = _newProviderController.text.trim();
                if (newProvider.isNotEmpty && !providers.contains(newProvider)) {
                  setState(() {
                    providers.add(newProvider);
                    _selectedProvider = newProvider;
                    ProviderManager.instance.addProvider(newProvider);
                  });
                }
                _newProviderController.clear();
                Navigator.pop(context);
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Producto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔹 **Campo de Producto (Autocompletable)**
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                return existingProducts.where((product) =>
                    product.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (selection) {
                _descriptionController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: _descriptionController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: "Producto"),
                );
              },
            ),

            /// 🔹 **Campo de Cantidad**
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: "Cantidad"),
              keyboardType: TextInputType.number,
            ),

            /// 🔹 **Ubicación (Lista desplegable)**
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(labelText: "Ubicación"),
              items: locations.map((location) {
                return DropdownMenuItem(value: location, child: Text(location));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),

            /// 🔹 **Categoría (Lista desplegable + Agregar)**
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: "Categoría"),
                    items: categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _showAddCategoryDialog),
              ],
            ),

            /// 🔹 **Proveedor (Lista desplegable + Agregar)**
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    decoration: const InputDecoration(labelText: "Proveedor"),
                    items: providers.map((provider) {
                      return DropdownMenuItem(value: provider, child: Text(provider));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProvider = value;
                      });
                    },
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _showAddProviderDialog),
              ],
            ),

            /// 🔹 **Botón para guardar el producto**
            ElevatedButton(onPressed: _saveProduct, child: const Text("Guardar Producto")),
          ],
        ),
      ),
    );
  }
}
