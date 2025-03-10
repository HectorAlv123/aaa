import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:inventario_app/domain/managers/order_manager.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/order.dart';
import 'package:inventario_app/presentation/screens/add_guide_product_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_app/data/models/inventory_item.dart';

class IngressGuideFormScreen extends StatefulWidget {
  const IngressGuideFormScreen({super.key});

  @override
  _IngressGuideFormScreenState createState() => _IngressGuideFormScreenState();
}

class _IngressGuideFormScreenState extends State<IngressGuideFormScreen> {
  final TextEditingController _truckPlateController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _guideNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<Map<String, dynamic>> _products = [];
  File? _image;
  final Uuid uuid = const Uuid();

  final List<String> ubicaciones = ["Galpón Azul", "Galpón Verde", "Bodega de EPPs"];
  String selectedLocation = "Galpón Azul"; // Ubicación por defecto

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addProduct() async {
  final List<Map<String, dynamic>>? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddGuideProductScreen(products: _products),
    ),
  );

  if (result != null) {
    setState(() {
      _products.clear();
      _products.addAll(result);
    });
  }
}

  void _saveGuide() {
    if (_providerController.text.isEmpty ||
        _guideNumberController.text.isEmpty ||
        _truckPlateController.text.isEmpty ||
        _driverNameController.text.isEmpty ||
        _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos y agrega productos.")),
      );
      return;
    }

    final newOrder = Order(
      id: uuid.v4(),
      guiaIngreso: _guideNumberController.text,
      proveedor: _providerController.text,
      ubicacionRecepcion: selectedLocation,
      truckPlate: _truckPlateController.text,
      driverName: _driverNameController.text,
      products: _products.map((product) {
        return InventoryItem(
          id: uuid.v4(),
          description: product["name"].toString(),
          guiaIngreso: _guideNumberController.text,
          quantity: product["quantity"],
          receiver: "Recepción",
          receptionDateTime: DateTime.now(),
          location: selectedLocation, // 🔹 Se guarda con la ubicación de descarga
          category: product["category"],
        );
      }).toList(),
      fotoGuia: _image?.path,
      isFinalized: true,
    );

    // Guardar la guía en memoria
    OrderManager.instance.addOrder(newOrder);

    // 🔹 Sumar los productos al inventario en la ubicación seleccionada
    for (var product in newOrder.products) {
      InventoryManager.instance.addOrUpdateProduct(product);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Guía de Ingreso guardada y productos sumados al inventario.")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ingreso de Guía")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _providerController, decoration: const InputDecoration(labelText: "Proveedor")),
            TextField(controller: _guideNumberController, decoration: const InputDecoration(labelText: "Número de Guía")),
            TextField(controller: _truckPlateController, decoration: const InputDecoration(labelText: "Placa del Camión")),
            TextField(controller: _driverNameController, decoration: const InputDecoration(labelText: "Nombre del Conductor")),
            DropdownButtonFormField(
              value: selectedLocation,
              items: ubicaciones.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
              onChanged: (val) => setState(() => selectedLocation = val!),
              decoration: const InputDecoration(labelText: "Ubicación de Descarga"),
            ),
            ElevatedButton(onPressed: _addProduct, child: const Text("Agregar Productos")),
            ElevatedButton(onPressed: _saveGuide, child: const Text("Guardar Guía")),
          ],
        ),
      ),
    );
  }
}
