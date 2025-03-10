import 'dart:math';
import 'package:flutter/foundation.dart'; // ✅ Importa VoidCallback
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';

class FakeDataGenerator {
  static final Random _random = Random();
  static final Set<String> _categoriesSet = {}; // Para evitar duplicados en Categorías

  /// 📌 **Listas globales para almacenar los datos generados**
  static final List<String> vehiclePlates = [];
  static final List<String> drivers = [];
  static final List<String> recipients = [];
  static final List<String> providers = [];
  static final List<String> categories = []; // ✅ Lista global para categorías

  /// 📌 **Generar Productos Falsos con Fechas Aleatorias**
  static void generateFakeProducts() {
    List<Map<String, String>> sampleProducts = [
      {"name": "Martillo", "category": "Herramientas"},
      {"name": "Destornillador", "category": "Herramientas"},
      {"name": "Sierra", "category": "Materiales"},
      {"name": "Taladro", "category": "Herramientas"},
      {"name": "Casco de Seguridad", "category": "EPP"},
      {"name": "Guantes de Trabajo", "category": "EPP"},
      {"name": "Clavos", "category": "Consumibles"},
    ];

    List<String> locations = ["Galpón Azul", "Galpón Verde", "Bodega de EPPs"];
    List<String> receivers = ["Admin", "Bodega Central", "UsuarioX"];

    List<InventoryItem> newItems = [];

    for (var product in sampleProducts) {
      String location = locations[_random.nextInt(locations.length)];
      String receiver = receivers[_random.nextInt(receivers.length)];
      String category = product["category"]!;

      // 🔹 Generar una fecha aleatoria dentro de los últimos 60 días
      DateTime randomDate = DateTime.now().subtract(Duration(days: _random.nextInt(60)));

      newItems.add(
        InventoryItem(
          id: _random.nextInt(100000).toString(),
          description: product["name"]!,
          location: location,
          quantity: _random.nextInt(50) + 10,
          category: category,
          receiver: receiver,
          receptionDateTime: randomDate, // ✅ Fecha aleatoria
        ),
      );

      // ✅ Guardar la categoría en "Datos/Categorías" si aún no está registrada
      if (!_categoriesSet.contains(category)) {
        _categoriesSet.add(category);
        categories.add(category);
      }
    }

    InventoryManager.instance.loadInventory(newItems);
  }

  /// 📌 **Generar Datos de Prueba (Patentes, Conductores, Destinatarios, Proveedores)**
  static void generateTestData(VoidCallback onUpdate) {
    List<String> newPlates = _generateChileanPlates(5);
    List<String> newDrivers = ["Juan Pérez", "Carlos Muñoz", "María González", "Pedro Rojas", "Ana López"];
    List<String> newRecipients = ["Bodega Central", "Departamento de Obras", "Planta 1", "Planta 2", "Taller Mecánico"];
    List<String> newProviders = ["Ferretería Los Vilos", "Materiales El Constructor", "Sodimac", "Easy", "Construmart"];

    for (var recipient in newRecipients) {
      if (!recipients.contains(recipient)) {
        recipients.add(recipient);
        InventoryManager.instance.recipients.add(recipient);
      }
    }

    for (var provider in newProviders) {
      if (!providers.contains(provider)) {
        providers.add(provider);
      }
    }

    vehiclePlates.addAll(newPlates);
    drivers.addAll(newDrivers);

    onUpdate();
  }

  /// 📌 **Borrar Todos los Datos**
  static void clearAllData() {
    InventoryManager.instance.inventoryItems.clear();
    InventoryManager.instance.transferRecords.clear();
    print("🗑 Todos los datos fueron eliminados.");
  }

  /// 📌 **Generar patentes chilenas aleatorias**
  static List<String> _generateChileanPlates(int count) {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    return List.generate(count, (_) {
      String firstPart = String.fromCharCodes(
          List.generate(2, (_) => letters.codeUnitAt(_random.nextInt(letters.length))));

      String secondPart = (_random.nextInt(90) + 10).toString(); // 2 números (10-99)
      return "$firstPart$secondPart";
    });
  }
}
