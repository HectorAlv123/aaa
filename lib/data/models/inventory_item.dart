class InventoryItem {
  final String id;
  final String description;
  final String? guiaIngreso; // Cambio de guiaDespacho a guiaIngreso
  int quantity; // mutable
  final String receiver;
  final DateTime receptionDateTime;
  final String location;
  final String category;

  InventoryItem({
    required this.id,
    required this.description,
    this.guiaIngreso,
    required this.quantity,
    required this.receiver,
    required this.receptionDateTime,
    required this.location,
    required this.category,
  });
}

// Lista global del inventario
class InventoryStorage {
  static final List<InventoryItem> inventoryItems = [];
}