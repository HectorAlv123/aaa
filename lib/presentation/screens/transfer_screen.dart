import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';
import 'package:inventario_app/data/models/transfer_record.dart';
import 'package:intl/intl.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? selectedSourceLocation;
  String? selectedDestinationLocation;
  InventoryItem? selectedItem;
  int transferQuantity = 0;
  final TextEditingController deliveredByController = TextEditingController(text: "admin");

  final List<String> locations = ['Galpón Azul', 'Galpón Verde', 'Bodega de EPPs'];

  /// 🔹 **Obtener productos disponibles en la ubicación seleccionada**
  List<InventoryItem> get sourceItems {
    if (selectedSourceLocation == null) return [];
    return InventoryManager.instance.getItemsInLocation(selectedSourceLocation!);
  }

  /// 🔹 **Realizar transferencia**
  void _performTransfer() {
    if (selectedItem == null ||
        transferQuantity <= 0 ||
        selectedSourceLocation == null ||
        selectedDestinationLocation == null ||
        deliveredByController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos para realizar la transferencia.")),
      );
      return;
    }

    if (selectedItem!.quantity < transferQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cantidad insuficiente en el inventario.")),
      );
      return;
    }

    setState(() {
      InventoryManager.instance.performTransfer(
        item: selectedItem!,
        transferQuantity: transferQuantity,
        sourceLocation: selectedSourceLocation!,
        destinationLocation: selectedDestinationLocation!,
        deliveredBy: deliveredByController.text,
      );
      selectedItem = null;
      transferQuantity = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transferencia realizada con éxito.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> destinationOptions = locations.where((loc) => loc != selectedSourceLocation).toList();
    List<TransferRecord> history = InventoryManager.instance.getTransferHistory();

    return Scaffold(
      appBar: AppBar(title: const Text("Transferencias")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSourceLocation,
              hint: const Text("Selecciona ubicación de origen"),
              items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
              onChanged: (val) {
                setState(() {
                  selectedSourceLocation = val;
                  selectedItem = null;
                  selectedDestinationLocation = null;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<InventoryItem>(
              value: selectedItem,
              hint: const Text("Selecciona producto a transferir"),
              items: sourceItems.map((item) => DropdownMenuItem(
                value: item,
                child: Text("${item.description} (Stock: ${item.quantity})"),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  selectedItem = val;
                });
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad a transferir"),
              onChanged: (val) {
                setState(() {
                  transferQuantity = int.tryParse(val) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedDestinationLocation,
              hint: const Text("Selecciona ubicación de destino"),
              items: destinationOptions.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
              onChanged: (val) {
                setState(() {
                  selectedDestinationLocation = val;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _performTransfer,
                child: const Text("Realizar Transferencia"),
              ),
            ),
            const Divider(height: 40),
            const Text(
              "Historial de Transferencias",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                return ListTile(
                  title: Text("${record.productName} (${record.quantity})"),
                  subtitle: Text(
                    "De: ${record.fromLocation}  →  ${record.toLocation}\n"
                    "Entregado por: ${record.deliveredBy}\n"
                    "Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(record.transferDateTime)}",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}