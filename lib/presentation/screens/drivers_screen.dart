import 'package:flutter/material.dart';
import 'package:inventario_app/core/utils/fake_data_generator.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  List<String> drivers = List.from(FakeDataGenerator.drivers);
  final TextEditingController _driverController = TextEditingController();

  /// 🔹 Agregar un conductor nuevo
  void _addDriver() {
    String driver = _driverController.text.trim();
    if (driver.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un nombre de conductor válido'))
      );
      return;
    }

    setState(() {
      drivers.add(driver);
      _driverController.clear();
    });

    Navigator.pop(context);
  }

  /// 🔹 Eliminar un conductor
  void _removeDriver(int index) {
    setState(() {
      drivers.removeAt(index);
    });
  }

  /// 🔹 Mostrar diálogo para agregar conductor
  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Conductor"),
          content: TextField(
            controller: _driverController,
            decoration: const InputDecoration(labelText: "Nombre del Conductor"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: _addDriver,
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
      appBar: AppBar(title: const Text("Conductores")),
      body: drivers.isEmpty
          ? const Center(child: Text("No hay conductores registrados"))
          : ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(drivers[index], style: const TextStyle(fontSize: 18)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDriver(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
