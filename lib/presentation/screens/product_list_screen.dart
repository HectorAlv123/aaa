import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';
import 'package:inventario_app/presentation/screens/add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  final bool isAdmin;
  final String warehouse;

  const ProductListScreen({
    super.key,
    required this.isAdmin,
    required this.warehouse,
  });

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchQuery = "";
  String selectedLocation = "Todas las ubicaciones";
  String selectedCategory = "Todas las categorías";

  final List<String> locations = [
    "Todas las ubicaciones",
    "Galpón Azul",
    "Galpón Verde",
    "Bodega de EPPs"
  ];

  final List<String> categories = [
    "Todas las categorías",
    "Materiales",
    "Herramientas",
    "EPP",
    "Otros"
  ];

  List<InventoryItem> get filteredItems {
    List<InventoryItem> items = selectedLocation == "Todas las ubicaciones"
        ? InventoryManager.instance.inventoryItems
        : InventoryManager.instance.getItemsInLocation(selectedLocation);

    if (selectedCategory != "Todas las categorías") {
      items = items.where((item) => item.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return items;
  }

  void _sort<T>(
      Comparable<T> Function(InventoryItem item) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      filteredItems.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  int _getQuantityByLocation(String product, String location) {
    return filteredItems
        .where((item) => item.description == product && item.location == location)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  int _getTotalQuantity(String product) {
    return _getQuantityByLocation(product, "Galpón Azul") +
        _getQuantityByLocation(product, "Galpón Verde") +
        _getQuantityByLocation(product, "Bodega de EPPs");
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> uniqueProducts = filteredItems
        .map((item) => item.description)
        .toSet()
        .where((product) => _getTotalQuantity(product) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inventario (${widget.warehouse})",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, size: 30, color: Colors.white),
            onPressed: () {},
            tooltip: "Exportar a Excel",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Buscar producto",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedLocation,
                            decoration: const InputDecoration(labelText: "Ubicación"),
                            items: locations.map((loc) {
                              return DropdownMenuItem(value: loc, child: Text(loc));
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedLocation = val!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(labelText: "Categoría"),
                            items: categories.map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat));
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCategory = val!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    sortAscending: _sortAscending,
                    sortColumnIndex: _sortColumnIndex,
                    columns: [
                      DataColumn(
                        label: const Text("Producto"),
                        onSort: (columnIndex, ascending) =>
                            _sort<String>((item) => item.description, columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text("Categoría"),
                        onSort: (columnIndex, ascending) =>
                            _sort<String>((item) => item.category, columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text("Galpón Azul"),
                        numeric: true,
                        onSort: (columnIndex, ascending) =>
                            _sort<num>((item) => _getQuantityByLocation(item.description, "Galpón Azul"), columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text("Galpón Verde"),
                        numeric: true,
                        onSort: (columnIndex, ascending) =>
                            _sort<num>((item) => _getQuantityByLocation(item.description, "Galpón Verde"), columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text("Bodega de EPPs"),
                        numeric: true,
                        onSort: (columnIndex, ascending) =>
                            _sort<num>((item) => _getQuantityByLocation(item.description, "Bodega de EPPs"), columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text("Total"),
                        numeric: true,
                        onSort: (columnIndex, ascending) =>
                            _sort<num>((item) => _getTotalQuantity(item.description), columnIndex, ascending),
                      ),
                    ],
                    rows: uniqueProducts.map((product) {
                      return DataRow(cells: [
                        DataCell(Text(product)),
                        DataCell(Text(filteredItems.firstWhere((item) => item.description == product).category)),
                        DataCell(Text(_getQuantityByLocation(product, "Galpón Azul").toString())),
                        DataCell(Text(_getQuantityByLocation(product, "Galpón Verde").toString())),
                        DataCell(Text(_getQuantityByLocation(product, "Bodega de EPPs").toString())),
                        DataCell(Text(_getTotalQuantity(product).toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        icon: const Icon(Icons.add),
        label: const Text("Agregar Producto"),
        backgroundColor: Colors.blue.shade800,
      ),
    );
  }
}
