import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_app/data/models/inventory_item.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/domain/managers/category_manager.dart';

class OrderScreen extends StatefulWidget {
  final String guiaIngreso;

  const OrderScreen({super.key, required this.guiaIngreso});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _proveedorController = TextEditingController();
  List<InventoryItem> orderProducts = [];
  String? proveedor;
  String? fotoGuia;
  final List<String> ubicaciones = ['Galpón Azul', 'Galpón Verde', 'Bodega de EPPs'];
  final Uuid uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _proveedorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        fotoGuia = pickedFile.path;
      });
    }
  }

  void _addProduct() async {
    if (proveedor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero ingresa el proveedor.")),
      );
      return;
    }
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final List<String> existingProducts = InventoryManager.instance.inventoryItems
        .map((item) => item.description)
        .toSet()
        .toList();
    String selectedLocation = ubicaciones.first;
    final List<String> catOptions = CategoryManager.instance.categories.isNotEmpty
        ? CategoryManager.instance.categories
        : ['Sin categoría'];
    String selectedCategory = catOptions.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Agregar producto al pedido"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                    return existingProducts.where((option) => option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    descriptionController.text = selection;
                  },
                  fieldViewBuilder: (context, textEditingController, fieldFocusNode, onFieldSubmitted) {
                    return TextField(
                      controller: descriptionController,
                      focusNode: fieldFocusNode,
                      decoration: const InputDecoration(labelText: "Producto"),
                    );
                  },
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "Cantidad"),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedLocation,
                  items: ubicaciones.map((loc) {
                    return DropdownMenuItem(
                      value: loc,
                      child: Text(loc),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setStateDialog(() {
                      if (val != null) {
                        selectedLocation = val;
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: "Ubicación de Descarga"),
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
                  final int qty = int.tryParse(quantityController.text.trim()) ?? 0;
                  if (descriptionController.text.trim().isEmpty || qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Datos inválidos")),
                    );
                    return;
                  }
                  final newProduct = InventoryItem(
                    id: uuid.v4(),
                    description: descriptionController.text.trim(),
                    guiaIngreso: widget.guiaIngreso,
                    quantity: qty,
                    receiver: "Pedido",
                    receptionDateTime: DateTime.now(),
                    location: selectedLocation, // ✅ Se asigna la ubicación de descarga
                    category: selectedCategory, // ✅ Se asigna la categoría seleccionada
                  );
                  setState(() {
                    orderProducts.add(newProduct);
                  });
                  InventoryManager.instance.addOrUpdateProduct(newProduct); // ✅ Se actualiza el inventario sumando valores
                  Navigator.of(context).pop();
                },
                child: const Text("Agregar"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos con Guía")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (fotoGuia != null)
              Column(
                children: [
                  const Text("Foto adjunta:"),
                  Image.file(File(fotoGuia!), height: 150),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(),
                    icon: const Icon(Icons.download),
                    label: const Text("Adjuntar Foto de la Guía"),
                  ),
                ],
              ),
            ElevatedButton(onPressed: _addProduct, child: const Text("Agregar Producto")),
          ],
        ),
      ),
    );
  }
}