import 'package:flutter/material.dart';
import 'package:inventario_app/core/utils/fake_data_generator.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  List<String> providers = List.from(FakeDataGenerator.providers);
  final TextEditingController _providerController = TextEditingController();

  void _addProvider() {
    String provider = _providerController.text.trim();

    if (provider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un nombre de proveedor válido')),
      );
      return;
    }

    setState(() {
      providers.add(provider);
      _providerController.clear();
    });

    Navigator.pop(context, provider); // ✅ Devuelve el nuevo proveedor seleccionado
  }

  void _removeProvider(int index) {
    setState(() {
      providers.removeAt(index);
    });
  }

  void _showAddProviderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Proveedor"),
          content: TextField(
            controller: _providerController,
            decoration: const InputDecoration(labelText: "Nombre del Proveedor"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: _addProvider,
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
      appBar: AppBar(title: const Text("Proveedores")),
      body: providers.isEmpty
          ? const Center(child: Text("No hay proveedores registrados"))
          : ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.store, color: Colors.blue),
                  title: Text(providers[index], style: const TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context, providers[index]); // ✅ Devuelve el proveedor seleccionado
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeProvider(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProviderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
