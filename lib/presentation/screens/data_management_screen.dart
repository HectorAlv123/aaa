import 'package:flutter/material.dart';
import 'package:inventario_app/presentation/screens/category_screen.dart';
import 'package:inventario_app/presentation/screens/supplier_management_screen.dart';
import 'package:inventario_app/presentation/screens/recipients_screen.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestión de Datos"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.category), text: "Categorías"),
              Tab(icon: Icon(Icons.store), text: "Proveedores"),
              Tab(icon: Icon(Icons.people), text: "Destinatarios"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CategoryScreen(),  // ✅ Categorías
            SupplierManagementScreen(),  // ✅ Proveedores
            RecipientsScreen(), // ✅ Destinatarios
          ],
        ),
      ),
    );
  }
}
