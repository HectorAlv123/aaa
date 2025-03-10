import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  _SupplierManagementScreenState createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  @override
  Widget build(BuildContext context) {
    List<String> suppliers = InventoryManager.instance.suppliers;

    return Scaffold(
      appBar: AppBar(title: const Text("Proveedores")),
      body: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suppliers[index]),
            leading: const Icon(Icons.store),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  InventoryManager.instance.suppliers.remove(suppliers[index]);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
