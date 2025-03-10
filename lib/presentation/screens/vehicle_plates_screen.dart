import 'package:flutter/material.dart';
import 'dart:math';

class VehiclePlatesScreen extends StatefulWidget {
  const VehiclePlatesScreen({super.key});

  @override
  _VehiclePlatesScreenState createState() => _VehiclePlatesScreenState();
}

class _VehiclePlatesScreenState extends State<VehiclePlatesScreen> {
  List<String> vehiclePlates = []; // 🔹 Lista editable de patentes
  final TextEditingController _plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateFakeData(); // 🔹 Solo para pruebas, se eliminará en producción
  }

  /// 🔹 Genera datos falsos de prueba
  void _generateFakeData() {
    for (int i = 0; i < 5; i++) {
      vehiclePlates.add(_generateRandomPlate());
    }
  }

  /// 🔹 Genera una patente en formato chileno: 4 consonantes + 2 números (Ej: "BCDF-12")
  String _generateRandomPlate() {
    const consonants = "BCDFGHJKLMNPRSTVWXYZ";
    final random = Random();
    String letters = String.fromCharCodes(List.generate(4, (_) => consonants.codeUnitAt(random.nextInt(consonants.length))));
    String numbers = "${random.nextInt(10)}${random.nextInt(10)}";
    return "$letters-$numbers";
  }

  /// 🔹 Agregar una nueva patente
  void _addPlate() {
    String plate = _plateController.text.trim().toUpperCase();
    final regex = RegExp(r'^[BCDFGHJKLMNPRSTVWXYZ]{4}-\d{2}$');

    if (plate.isEmpty || !regex.hasMatch(plate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una patente válida (4 consonantes - 2 números)'))
      );
      return;
    }

    setState(() {
      vehiclePlates.add(plate);
      _plateController.clear();
    });

    Navigator.pop(context); // 🔹 Cierra el diálogo después de agregar
  }

  /// 🔹 Eliminar una patente
  void _removePlate(int index) {
    setState(() {
      vehiclePlates.removeAt(index);
    });
  }

  /// 🔹 Mostrar diálogo para agregar patente
  void _showAddPlateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Patente"),
          content: TextField(
            controller: _plateController,
            decoration: const InputDecoration(labelText: "Ej: BCDF-12"),
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: _addPlate,
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
      appBar: AppBar(title: const Text("Vehículos")),
      body: ListView.builder(
        itemCount: vehiclePlates.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.blue),
            title: Text(vehiclePlates[index], style: const TextStyle(fontSize: 18)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removePlate(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
