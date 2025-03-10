// lib/domain/managers/inventory_manager.dart

import 'package:inventario_app/data/models/inventory_item.dart';
import 'package:inventario_app/data/models/transfer_record.dart';

class InventoryManager {
  static final InventoryManager instance = InventoryManager._privateConstructor();
  InventoryManager._privateConstructor();

  List<InventoryItem> inventoryItems = [
    InventoryItem(id: '1', description: 'Tornillo', location: 'Galpón Azul', quantity: 10, category: 'Fijaciones', receiver: 'Admin', receptionDateTime: DateTime.now()),
    InventoryItem(id: '2', description: 'Martillo', location: 'Galpón Verde', quantity: 5, category: 'Herramientas', receiver: 'Admin', receptionDateTime: DateTime.now()),
  ];

  List<TransferRecord> transferRecords = [];

  // 🔹 **Realizar transferencia de productos**
  void performTransfer({
    required InventoryItem item,
    required int transferQuantity,
    required String sourceLocation,
    required String destinationLocation,
    required String deliveredBy,
  }) {
    if (item.quantity < transferQuantity) {
      throw Exception("Cantidad insuficiente en el inventario.");
    }

    // Restar cantidad en la ubicación de origen
    item.quantity -= transferQuantity;
    if (item.quantity == 0) {
      inventoryItems.removeWhere((prod) => prod.id == item.id);
    }

    // Buscar si el producto ya existe en la ubicación de destino
    InventoryItem? destItem = inventoryItems.firstWhere(
      (prod) => prod.location == destinationLocation && prod.description == item.description,
      orElse: () => InventoryItem(
        id: '',  // Se asignará un nuevo ID si no existe
        description: '',
        location: '',
        quantity: 0,
        category: '',
        receiver: '',
        receptionDateTime: DateTime.now(),
      ),
    );

    if (destItem.id.isEmpty) {  
      // 🆕 Si no existe en la ubicación de destino, creamos un NUEVO producto con un ID único
      InventoryItem newItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: item.description,
        location: destinationLocation,
        quantity: transferQuantity,
        category: item.category,
        receiver: deliveredBy,
        receptionDateTime: DateTime.now(),
      );
      inventoryItems.add(newItem);
    } else {
      // ✅ Si ya existe, simplemente aumentamos su cantidad
      destItem.quantity += transferQuantity;
    }

    // 📝 **Registrar la transferencia**
    transferRecords.add(TransferRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: item.id,
      productName: item.description,
      quantity: transferQuantity,
      deliveredBy: deliveredBy,
      fromLocation: sourceLocation,
      toLocation: destinationLocation,
      transferDateTime: DateTime.now(),
    ));
  }
}
