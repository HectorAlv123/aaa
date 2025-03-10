import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/presentation/screens/add_dispatch_voucher_screen.dart';

class DispatchVoucherListScreen extends StatefulWidget {
  const DispatchVoucherListScreen({super.key});

  @override
  _DispatchVoucherListScreenState createState() => _DispatchVoucherListScreenState();
}

class _DispatchVoucherListScreenState extends State<DispatchVoucherListScreen> {
  List<Map<String, dynamic>> vouchers = [];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  void _loadVouchers() {
    setState(() {
      vouchers = InventoryManager.instance.getDispatchVouchers();
      
      // 📌 Depuración: imprimir vales de despacho al cargar
      print("📌 Vales de despacho al cargar:");
      for (var voucher in vouchers) {
        print("🔹 Vale N° ${voucher["voucherNumber"]} - Destinatario: ${voucher["recipient"]}");
        for (var product in (voucher["products"] as List?) ?? []) {
          print("    - ${product["name"]} - ${product["quantity"]} uds en ${product["location"]}");
        }
      }
    });
  }

  Future<void> _navigateToAddVoucher() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDispatchVoucherScreen()),
    );
    if (result == true) {
      _loadVouchers();
    }
  }

  void _deleteVoucher(int index) {
    InventoryManager.instance.removeDispatchVoucher(index);
    _loadVouchers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vales de Salida")),
      body: vouchers.isEmpty
          ? const Center(child: Text("No hay vales registrados"))
          : ListView.builder(
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                final List<Map<String, dynamic>> products = (voucher['products'] as List?)
                        ?.map<Map<String, dynamic>>((p) => Map<String, dynamic>.from(p))
                        .toList() ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    title: Text("Vale N° ${voucher['voucherNumber'] ?? 'Sin número'}"),
                    subtitle: Text("📌 Destinatario: ${voucher['recipient'] ?? 'Desconocido'}\n"
                        "📅 Fecha: ${(voucher['date'] as DateTime?)?.toLocal().toString().split(' ')[0] ?? 'Sin fecha'}"),
                    children: products.map((product) {
                      return ListTile(
title: Text((product["name"] ?? product["product"] ?? product["description"] ?? "❌ Producto sin nombre").toString()),
                        subtitle: Text("Cantidad entregada: ${product['quantity'] ?? 0}"),
                      );
                    }).toList(),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteVoucher(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVoucher,
        backgroundColor: Colors.blueAccent,
        tooltip: "Agregar Nuevo Vale",
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
