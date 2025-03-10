// lib/models/order.dart
import 'inventory_item.dart';

class Order {
  final String id;
  final String guiaIngreso;
  final String proveedor;
  final String ubicacionRecepcion;
  final List<InventoryItem> products;
  final String? fotoGuia;
  final bool isFinalized;
  final bool isIngress; // ✅ Agregamos este campo para identificar Guías de Ingreso
  final String truckPlate;  // 🆕 Patente del camión
  final String driverName;  // 🆕 Nombre del conductor


  Order({
    required this.id,
    required this.guiaIngreso,
    required this.proveedor,
    required this.ubicacionRecepcion,
    required this.products,
    this.fotoGuia,
    this.isFinalized = false,
    this.isIngress = false,
    required this.truckPlate,   // 🆕 Ahora es obligatorio
    required this.driverName,   // 🆕 Ahora es obligatorio
  });
}
