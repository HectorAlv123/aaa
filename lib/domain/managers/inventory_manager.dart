import 'package:inventario_app/data/models/inventory_item.dart';
import 'package:inventario_app/data/models/transfer_record.dart';

class InventoryManager {
  static final InventoryManager instance = InventoryManager._privateConstructor();
  InventoryManager._privateConstructor();

  List<InventoryItem> inventoryItems = []; // 🔹 Inventario almacenado en memoria
  List<TransferRecord> transferRecords = []; // 🔹 Historial de transferencias
  List<Map<String, dynamic>> dispatchVouchers = []; // 🔹 Lista de vales de despacho
  List<Map<String, dynamic>> ingressGuides = []; // 🔹 Lista de Guías de Ingreso
  List<Map<String, dynamic>> movements = []; // ✅ Lista global de movimientos

  /// 🔹 **Obtener historial de stock de un producto**
  List<Map<String, dynamic>> getStockHistory(String productName) {
    List<Map<String, dynamic>> stockHistory = [];

    // 🔹 Buscar movimientos de ingreso y salida
    for (var movement in movements) {
      if (movement["name"].contains(productName)) {
        stockHistory.add({
          "action": movement["type"],
          "date": movement["date"],
          "quantity": movement["type"] == "Salida" ? -1 : 1, // 🔹 Ajusta cantidades
        });
      }
    }

    return stockHistory;
  }

  /// 🔹 **Registrar un nuevo movimiento en el historial**
  /// 🔹 **Registrar un nuevo movimiento en el historial**

void addMovement(String name, String type, int quantity, String location, DateTime date, {String details = ""}) {
  movements.add({
    "date": date,
    "name": name,
    "type": type,
    "quantity": quantity,
    "location": location,
    "details": details, // ✅ Guardar detalles del movimiento
  });
}






  /// 🔹 **Obtener todos los vales de despacho almacenados**
  List<Map<String, dynamic>> getDispatchVouchers() {
    return dispatchVouchers;
  }

  /// 🔹 **Agregar un vale de salida y registrar en movimientos**
  /// 🔹 **Agregar un vale de salida y registrar en movimientos**
  
void addDispatchVoucher(String recipient, List<InventoryItem> items, String voucherNumber, DateTime date) {
  // 🔹 Lista para almacenar los productos del vale con sus detalles
  List<Map<String, Object>> productDetails = [];

  for (var item in items) {
    if (item.quantity > 0) {
      try {
        // ✅ Registrar cada producto como salida en `movements`
        addMovement(
  item.description ?? "Producto desconocido", // ✅ Asegurar que el nombre se guarda correctamente
  "Salida", 
  item.quantity, 
  item.location, 
  date,
  details: "Vale de Salida N° $voucherNumber - Destinatario: $recipient"
);


        // ✅ Descontar del inventario
        updateInventoryQuantity(item.description ?? "Producto sin nombre", item.location, -item.quantity);

        String safeName = (item.description ?? "Producto sin nombre").trim();
if (safeName.isEmpty) {
  print("⚠️ Advertencia: Producto sin nombre detectado antes de guardar el vale.");
  safeName = "Producto sin nombre"; // ✅ Forzar nombre válido
}

productDetails.add({
  "name": safeName, // 🔹 Siempre guardar como "name"
  "quantity": item.quantity,
  "location": item.location,
});


      } catch (e) {
        print("⚠️ Error al procesar producto en el vale: $e");
      }
    }
  }

  // ✅ Registrar el vale como un movimiento agrupado en `movements`
  try {
    movements.add({
      "voucherNumber": voucherNumber,
      "recipient": recipient,
      "date": date,
      "type": "Vale de Salida",
      "quantity": items.fold(0, (sum, item) => sum + item.quantity), // Cantidad total
      "location": "Bodega",
      "products": List<Map<String, Object>>.from(productDetails), // ✅ Crear una copia segura
      "isExpanded": false,
    });
  } catch (e) {
    print("⚠️ Error al registrar el vale de salida en movements: $e");
  }

  // ✅ Guardar el vale en la lista de vales de despacho
  try {
    dispatchVouchers.add({
      "voucherNumber": voucherNumber,
      "recipient": recipient,
      "date": date, // Se mantiene como DateTime
      "products": List<Map<String, Object>>.from(productDetails), // ✅ Crear una copia segura
    });
  } catch (e) {
    print("⚠️ Error al guardar el vale en la lista: $e");
  }
}




  /// 🔹 **Eliminar un vale de despacho y reponer stock**
  void removeDispatchVoucher(int index) {
  if (index < dispatchVouchers.length) {
    var voucher = dispatchVouchers[index];

    // ✅ Restaurar stock de productos
    for (var product in voucher["products"]) {
      updateInventoryQuantity(product["description"], product["location"], product["quantity"]);
      addMovement(
        product["description"],
        "Reposición",
        product["quantity"] as int,
        product["location"],
        DateTime.now(),
      );
    }

    dispatchVouchers.removeAt(index);

    // ✅ Eliminar el movimiento del vale en `movements`
    movements.removeWhere((movement) => 
      movement["voucherNumber"] == voucher["voucherNumber"] &&
      movement["type"] == "Vale de Salida"
    );

    // ✅ Registrar la eliminación en el historial de movimientos
    addMovement(
      "Anulación del Vale N° ${voucher["voucherNumber"]}",
      "Anulación",
      0,
      "",
      DateTime.now(),
    );
  }
}


  /// 🔹 **Obtener TODAS las ubicaciones (independiente de stock)**
  List<String> getLocations() {
    return inventoryItems.map((item) => item.location).toSet().toList();
  }

  /// 🔹 **Obtener categorías de productos**
  List<String> get categories => ['Electrónica', 'Ropa', 'Alimentos', 'Materiales'];

  /// 🔹 **Cargar inventario desde una fuente externa**
  void loadInventory(List<InventoryItem> items) {
    inventoryItems = items;
  }

  /// 🔹 **Agregar un producto nuevo al inventario**
  void addProduct(InventoryItem item, {String? supplier}) {
    inventoryItems.add(item);
    print('Producto agregado: ${item.description}');

    if (supplier != null) {
      print('Proveedor asociado: $supplier');
    }
  }

  /// 🔹 **Agregar o actualizar un producto en el inventario**
  void addOrUpdateProduct(InventoryItem product) {
    final existingProduct = inventoryItems.firstWhere(
      (item) => item.description.toLowerCase() == product.description.toLowerCase() && item.location == product.location,
      orElse: () => InventoryItem(
        id: "",
        description: "",
        guiaIngreso: "",
        quantity: 0,
        receiver: "",
        receptionDateTime: DateTime.now(),
        location: "",
        category: "",
      ),
    );

    if (existingProduct.id.isNotEmpty) {
      // 🔹 Si el producto ya existe en la misma ubicación, sumar la cantidad
      existingProduct.quantity += product.quantity;
    } else {
      // 🔹 Si no existe, agregarlo como nuevo
      inventoryItems.add(product);
    }
  }

  /// 🔹 **Obtener productos disponibles en una ubicación específica**
  List<InventoryItem> getItemsInLocation(String location) {
    return inventoryItems.where((item) => item.location == location && item.quantity > 0).toList();
  }

  /// 🔹 **Actualizar la cantidad de un producto en el inventario**
  void updateInventoryQuantity(String description, String location, int quantityChange) {
    for (var item in inventoryItems) {
      if (item.description == description && item.location == location) {
        item.quantity += quantityChange;
        if (item.quantity < 0) {
          item.quantity = 0; // 🔹 Evitar valores negativos
        }
        break;
      }
    }
  }

  /// 🔹 **Realizar transferencia de productos entre ubicaciones**
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
        id: '',
        description: '',
        location: '',
        quantity: 0,
        category: '',
        receiver: '',
        receptionDateTime: DateTime.now(),
      ),
    );

    if (destItem.id.isEmpty) {
      // 🆕 Si no existe en la ubicación de destino, creamos un NUEVO producto
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

  /// 🔹 **Obtener historial de transferencias**
  List<TransferRecord> getTransferHistory() {
    return transferRecords;
  }

  /// 🔹 **Obtener destinatarios únicos**
  List<String> get recipients => inventoryItems.map((item) => item.receiver).toSet().toList();

  /// 🔹 **Obtener proveedores**
  List<String> get suppliers => ['Proveedor 1', 'Proveedor 2', 'Proveedor 3'];
}
