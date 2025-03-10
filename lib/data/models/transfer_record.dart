class TransferRecord {
  final String id;
  final String productId;
  final String productName; // Agregado para la descripción
  final int quantity;
  final String fromLocation;
  final String toLocation;
  final String deliveredBy;
  final DateTime transferDateTime;

  TransferRecord({
    required this.id,
    required this.productId,
    required this.productName, // Agregado
    required this.quantity,
    required this.fromLocation,
    required this.toLocation,
    required this.deliveredBy,
    required this.transferDateTime,
  });
}
