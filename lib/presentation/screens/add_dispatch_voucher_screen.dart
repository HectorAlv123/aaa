import 'package:flutter/material.dart';
import 'package:inventario_app/data/models/inventory_item.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/domain/managers/recipient_manager.dart';
import 'package:inventario_app/presentation/screens/recipients_screen.dart';
import 'package:inventario_app/presentation/screens/select_products_screen.dart';

class AddDispatchVoucherScreen extends StatefulWidget {
  const AddDispatchVoucherScreen({Key? key}) : super(key: key);

  @override
  _AddDispatchVoucherScreenState createState() => _AddDispatchVoucherScreenState();
}

class _AddDispatchVoucherScreenState extends State<AddDispatchVoucherScreen> {
  final TextEditingController _voucherNumberController = TextEditingController();
  final TextEditingController _newRecipientController = TextEditingController();
  String? _selectedRecipient;
  List<Map<String, dynamic>> _selectedProducts = [];
  final InventoryManager _inventoryManager = InventoryManager.instance;

  DateTime _selectedDate = DateTime.now(); // ✅ Fecha por defecto (actual)

  void _loadRecipients() async {
    final selectedRecipient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipientsScreen()),
    );

    if (selectedRecipient != null && mounted) {
      setState(() {
        _selectedRecipient = selectedRecipient;
      });
    }
  }

  void _addNewRecipient() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Destinatario'),
          content: TextField(
            controller: _newRecipientController,
            decoration: const InputDecoration(labelText: 'Nombre del Destinatario'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                String newRecipient = _newRecipientController.text.trim();
                if (newRecipient.isNotEmpty) {
                  setState(() {
                    RecipientManager.instance.addRecipient(newRecipient);
                    _selectedRecipient = newRecipient;
                    _newRecipientController.clear();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _selectProducts() async {
    final selectedProducts = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectProductsScreen(initialProducts: _selectedProducts)),
    );

    if (selectedProducts != null) {
      setState(() {
        _selectedProducts = selectedProducts;
      });
    }
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate; // ✅ Actualiza la fecha seleccionada
      });
    }
  }

  void _saveVoucher() {
    if (_selectedRecipient == null || _voucherNumberController.text.isEmpty || _selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos y agregue productos.'))
      );
      return;
    }

    print("📌 Productos seleccionados antes de guardar el vale:");
    for (var product in _selectedProducts) {
      print("✅ ${product["description"]} - ${product["quantity"]} uds en ${product["location"]}");
    }

    // ✅ Convertir los productos seleccionados a `InventoryItem`
    List<InventoryItem> items = _selectedProducts.map((product) {
      return InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: product["description"] ?? "Producto desconocido", // ✅ Validación
        location: product["location"] ?? "Ubicación desconocida",
        category: product["category"] ?? "Sin categoría",
        quantity: product["quantity"] ?? 0,
        receiver: _selectedRecipient!,
        receptionDateTime: _selectedDate,
      );
    }).toList();

    print("📌 Lista de productos convertidos a InventoryItem:");
    for (var item in items) {
      print("🔹 ${item.description} - ${item.quantity} uds en ${item.location}");
    }

    // ✅ Registrar el vale de salida en `InventoryManager`
    _inventoryManager.addDispatchVoucher(_selectedRecipient!, items, _voucherNumberController.text, _selectedDate);

    // ✅ Registrar en el historial de movimientos con la fecha y hora
    _inventoryManager.addMovement(
      "Vale de Salida N° ${_voucherNumberController.text} - Destinatario: $_selectedRecipient", 
      "Salida", 
      0, // Cantidad (0 porque el vale contiene varios productos)
      "", // Ubicación vacía porque es un vale general
      _selectedDate
    );

    // ✅ Descontar las unidades del inventario en la ubicación correcta
    for (var product in _selectedProducts) {
      _inventoryManager.updateInventoryQuantity(
        product["description"] ?? "Producto desconocido",
        product["location"] ?? "Ubicación desconocida",
        -product["quantity"], // Restar la cantidad retirada
      );
    }

    // ✅ Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vale de salida registrado con éxito.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // ✅ Regresar a la pantalla anterior
    Navigator.pop(context, true);

    print("📌 Vales de despacho guardados después de agregar:");
    for (var voucher in _inventoryManager.dispatchVouchers) {
      print("🔹 Vale N° ${voucher["voucherNumber"]} - ${voucher["recipient"]}");
      for (var product in voucher["products"]) {
        print("    - ${product["name"]} - ${product["quantity"]} uds en ${product["location"]}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Vale de Despacho')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _loadRecipients,
              child: Text(_selectedRecipient ?? 'Seleccionar Destinatario'),
            ),
            TextField(
              controller: _voucherNumberController,
              decoration: const InputDecoration(labelText: 'Número de Vale'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            /// 🔹 **Selector de Fecha**
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Fecha del Vale: ${_selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectProducts,
              child: const Text('Agregar Lista de Productos'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = _selectedProducts[index];
                  return ListTile(
                    title: Text('${product["description"]} - ${product["quantity"]} unidades'),
                    subtitle: Text('Ubicación: ${product["location"]}, Categoría: ${product["category"]}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveVoucher,
              child: const Text('Finalizar Vale'),
            ),
          ],
        ),
      ),
    );
  }
}
