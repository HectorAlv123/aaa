import 'package:flutter/material.dart';
import 'package:inventario_app/core/utils/fake_data_generator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {"title": "Inventario", "icon": Icons.inventory, "color": Colors.blue, "route": "/inventory"},
      {"title": "Transferencias", "icon": Icons.sync_alt, "color": Colors.orange, "route": "/transfer"},
      {"title": "Datos", "icon": Icons.category, "color": Colors.green, "route": null},
      {"title": "📊 Estadísticas", "icon": Icons.bar_chart, "color": Colors.red, "route": "/statistics"},
      {"title": "Vales de Salida", "icon": Icons.receipt_long, "color": Colors.teal, "route": "/dispatchVouchers"},
      {"title": "Guías de Ingreso", "icon": Icons.assignment_turned_in, "color": Colors.purple, "route": "/ingressGuides"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: options.map((option) {
                  return Card(
                    color: option["color"],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(option["icon"], size: 40, color: Colors.white),
                      title: Text(
                        option["title"],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      onTap: () {
                        if (option["route"] != null) {
                          Navigator.pushNamed(context, option["route"]).then((_) => setState(() {}));
                        } else {
                          _showDataMenu(context);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showFakeDataMenu(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                backgroundColor: Colors.green,
              ),
              child: const Text(
                "Generar Datos de Prueba",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **Menú para "Datos"**
  void _showDataMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.category, color: Colors.green),
              title: const Text("Categorías"),
              onTap: () {
                Navigator.pushNamed(context, "/categories").then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text("Proveedores"),
              onTap: () {
                Navigator.pushNamed(context, "/providers").then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.orange),
              title: const Text("Destinatarios"),
              onTap: () {
                Navigator.pushNamed(context, "/recipients").then((_) => setState(() {}));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.purple),
              title: const Text("Patentes de Vehículo"),
              onTap: () {
                Navigator.pushNamed(context, "/vehiclePlates").then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge, color: Colors.indigo),
              title: const Text("Conductores"),
              onTap: () {
                Navigator.pushNamed(context, "/drivers").then((_) => setState(() {}));
              },
            ),
          ],
        );
      },
    );
  }

  /// ✅ **Menú de generación de datos de prueba**
  void _showFakeDataMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                  title: const Text("Agregar Productos"),
                  onTap: () {
                    Navigator.pop(context);
                    FakeDataGenerator.generateFakeProducts();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car, color: Colors.green),
                  title: const Text("Generar Datos (Patentes, Conductores, Destinatarios)"),
                  onTap: () {
                    Navigator.pop(context);
                    FakeDataGenerator.generateTestData(() {
                      setState(() {});
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("Borrar Todos los Datos"),
                  onTap: () {
                    Navigator.pop(context);
                    FakeDataGenerator.clearAllData();
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
