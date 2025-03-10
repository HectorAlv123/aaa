import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';

class MovementsHistoryScreen extends StatefulWidget {
  const MovementsHistoryScreen({super.key});

  @override
  _MovementsHistoryScreenState createState() => _MovementsHistoryScreenState();
}

class _MovementsHistoryScreenState extends State<MovementsHistoryScreen> {
  List<Map<String, dynamic>> movements = [];
  List<Map<String, dynamic>> filteredMovements = [];
  String? selectedProduct;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  /// 🔹 **Carga los movimientos reales desde InventoryManager**
  /// 🔹 **Carga los movimientos reales desde InventoryManager**
void _loadMovements() {
  setState(() {
    movements = InventoryManager.instance.inventoryItems.map<Map<String, Object>>((item) {
      return {
        "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(item.receptionDateTime),
        "name": item.description ?? "Producto sin nombre",
        "type": "Ingreso",
        "product": item.description ?? "Producto sin nombre",
        "quantity": item.quantity as Object,
        "location": item.location ?? "Ubicación desconocida",
        "isExpanded": false,
      };
    }).toList();

    // 🔹 Agrupación de vales de salida por número de vale
    Map<String, Map<String, Object>> groupedVouchers = {};

    for (var movement in InventoryManager.instance.movements) {
      try {
        if (movement["type"] == "Vale de Salida" && movement.containsKey("voucherNumber")) {
          String voucherKey = movement["voucherNumber"].toString();

          if (!groupedVouchers.containsKey(voucherKey)) {
            groupedVouchers[voucherKey] = {
              "date": movement["date"] is DateTime
                  ? DateFormat("yyyy-MM-dd HH:mm:ss").format(movement["date"] as DateTime)
                  : movement["date"].toString(),
              "name": "Vale de Salida N° $voucherKey - Destinatario: ${movement["recipient"] ?? "Desconocido"}",
              "type": "Salida",
              "quantity": 0 as Object,
              "location": movement["location"]?.toString() ?? "Ubicación no especificada",
              "details": <String>[],
              "products": <Map<String, Object>>[], // ✅ Lista de productos inicializada correctamente
              "isExpanded": false,
            };
          }

          // 🔹 Obtener el nombre del producto de manera segura
String productName = movement["name"]?.toString()?.trim() ?? 
                     movement["product"]?.toString()?.trim() ?? 
                     movement["description"]?.toString()?.trim() ?? 
                     "Producto sin nombre";

if (productName.isEmpty || productName == "Producto sin nombre") {
  print("⚠️ Advertencia: Producto sin nombre detectado en _loadMovements: $movement");
}

          // ✅ Si hay productos sin nombre, imprimir una advertencia con más detalles
          if (movement["name"] == null || (movement["name"] as String).trim().isEmpty) {
  print("⚠️ Advertencia: Producto sin nombre detectado en movimiento: $movement");
  movement["name"] = "Producto sin nombre"; // ✅ Forzar un nombre válido
}


          // 🔹 Agregar la cantidad de productos al vale
          groupedVouchers[voucherKey]!["quantity"] = 
              ((groupedVouchers[voucherKey]!["quantity"] as int) + 
              ((movement["quantity"] is int) ? movement["quantity"] as int : 0)) as Object;

          // 🔹 Agregar el producto al campo "products" asegurando el formato correcto
          var productEntry = {
            "name": productName,
            "quantity": movement["quantity"] ?? 0,
            "location": movement["location"] ?? "Ubicación desconocida",
          };

          (groupedVouchers[voucherKey]!["products"] as List<Map<String, Object>>)
    .add(Map<String, Object>.from(productEntry));



          // 🔹 Agregar los productos al detalle del vale (para la expansión)
          (groupedVouchers[voucherKey]!["details"] as List<String>)
              .add("$productName (${movement["quantity"] ?? 0} uds)");

        } else {
          // 🔹 Movimiento individual (no es vale de salida)
          String productName = movement["name"]?.toString() ?? movement["product"]?.toString() ?? "Producto sin nombre";

          // ✅ Si hay productos sin nombre, imprimir una advertencia con más detalles
          if (productName == "Producto sin nombre") {
            print("⚠️ Advertencia: Producto sin nombre detectado en movimiento: $movement");
          }

          movements.add({
            "date": movement["date"] is DateTime
                ? DateFormat("yyyy-MM-dd HH:mm:ss").format(movement["date"] as DateTime)
                : movement["date"].toString(),
            "name": productName,
            "type": movement["type"]?.toString() ?? "Tipo desconocido",
            "quantity": (movement["quantity"] is int) ? movement["quantity"] as int : 0 as Object,
            "location": movement["location"]?.toString() ?? "Ubicación no especificada",
            "details": movement.containsKey("details") && movement["details"] != null
                ? movement["details"].toString()
                : "Sin detalles",
            "isExpanded": false,
          });
        }
      } catch (e) {
        print("⚠️ Error procesando un movimiento: $e \nMovimiento: $movement");
      }
    }

    // 🔹 Agregar los vales de salida agrupados a la lista de movimientos
    movements.addAll(groupedVouchers.values.map<Map<String, Object>>((voucher) {
      return {
        "date": voucher["date"]!,
        "name": voucher["name"]!,
        "type": voucher["type"]!,
        "quantity": voucher["quantity"]!,  
        "location": voucher["location"]!,
        "details": (voucher["details"] as List<String>).join(", "),
        "products": List<Map<String, Object>>.from(voucher["products"] as List), // ✅ Corrección de formato
        "isExpanded": false,
      };
    }).toList());

    // 🔹 Imprimir los movimientos para depuración
    print("📌 Movimientos después de cargar:");
    for (var movement in movements) {
      print("🔹 ${movement["name"]} - ${movement["type"]} - ${movement["quantity"]} en ${movement["location"]}");
    }

    filteredMovements = List.from(movements);
  });
}






  /// 🔹 **Filtrar por fecha**
  void _filterByDate(DateTime selectedDate) {
    setState(() {
      filteredMovements = movements.where((movement) {
        return DateFormat("yyyy-MM-dd").format(DateTime.parse(movement["date"])) ==
            DateFormat("yyyy-MM-dd").format(selectedDate);
      }).toList();
    });
  }

  /// 🔹 **Filtrar por tipo de movimiento**
  void _filterByType(String type) {
    setState(() {
      selectedType = type;
      filteredMovements = movements.where((movement) => movement["type"] == type).toList();
    });
  }

  /// 🔹 **Filtrar por producto**
  void _filterByProduct(String? product) {
    setState(() {
      selectedProduct = product;
      if (product == "Todos") {
        filteredMovements = List.from(movements);
      } else {
        filteredMovements = movements.where((movement) => movement["product"] == product).toList();
      }
    });
  }

  /// 🔹 **Restablecer filtros**
  void _resetFilters() {
    setState(() {
      selectedProduct = null;
      selectedType = null;
      filteredMovements = List.from(movements);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Movimientos")),
      body: Column(
        children: [
          _buildFilterButtons(),
          Expanded(child: _buildMovementsList()),
        ],
      ),
    );
  }

  /// 🔹 **Botones de filtro**
  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) _filterByDate(pickedDate);
                },
                child: const Text("Filtrar por Fecha"),
              ),
              DropdownButton<String>(
                hint: const Text("Tipo"),
                value: selectedType,
                onChanged: (String? newValue) {
                  if (newValue != null) _filterByType(newValue);
                },
                items: ["Ingreso", "Salida", "Transferencia", "Agregar Producto"]
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _resetFilters,
                child: const Text("Reset"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Producto: "),
              DropdownButton<String>(
                value: selectedProduct,
                hint: const Text("Seleccionar producto"),
                onChanged: (String? newValue) {
                  _filterByProduct(newValue);
                },
                items: [
                  "Todos",
                  ...InventoryManager.instance.inventoryItems.map((item) => item.description).toList(),
                ].map((product) => DropdownMenuItem(value: product, child: Text(product))).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }


/// 🔹 **Obtener icono según tipo de movimiento**
IconData _getIcon(String type) {
  switch (type) {
    case "Ingreso":
      return Icons.assignment_turned_in;
    case "Salida":
      return Icons.receipt_long;
    case "Transferencia":
      return Icons.sync_alt;
    case "Agregar Producto":
      return Icons.add_shopping_cart;
    default:
      return Icons.info;
  }
}

/// 🔹 **Obtener color según tipo de movimiento**
Color _getColor(String type) {
  switch (type) {
    case "Ingreso":
      return Colors.green;
    case "Salida":
      return Colors.red;
    case "Transferencia":
      return Colors.orange;
    case "Agregar Producto":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

  /// 🔹 **Lista de Movimientos**
  /// 🔹 **Lista de Movimientos**
/// 🔹 **Lista de Movimientos**
/// 🔹 **Lista de Movimientos**
Widget _buildMovementsList() {
  return ListView.builder(
    itemCount: filteredMovements.length,
    itemBuilder: (context, index) {
      final movement = filteredMovements[index];

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ExpansionTile(
          leading: Icon(_getIcon(movement["type"] as String), color: _getColor(movement["type"] as String)),
          title: Text(movement["name"]),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cantidad Total: ${movement["quantity"]} • Ubicación: ${movement["location"]}"),
              Text(
                "Fecha: ${movement["date"]}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          initiallyExpanded: movement["isExpanded"] ?? false,
          onExpansionChanged: (bool expanded) {
            setState(() {
              movement["isExpanded"] = expanded;
            });
          },
          children: movement["type"] == "Salida" && movement.containsKey("products")
    ? (movement["products"] as List<Map<String, Object>>)
        .map((product) {
          String productName = product.containsKey("name") && product["name"] != null
              ? product["name"].toString()
              : "Producto sin nombre";
          int productQuantity = product.containsKey("quantity") && product["quantity"] != null
              ? product["quantity"] as int
              : 0;
          String productLocation = product.containsKey("location") && product["location"] != null
              ? product["location"].toString()
              : "Ubicación desconocida";

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "🔹 $productName - $productQuantity uds (Ubicación: $productLocation)",
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList()
    : [const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Sin detalles disponibles", style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey)),
      )],

        ),
      );
    },
  );
}


}