// lib/managers/provider_manager.dart
class ProviderManager {
  static final ProviderManager instance = ProviderManager._internal();
  ProviderManager._internal();

  final Set<String> _providers = {};

  /// 📌 **Obtener la lista de proveedores**
  List<String> get providers => _providers.toList();

  /// 📌 **Agregar un nuevo proveedor**
  void addProvider(String provider) {
    if (provider.isNotEmpty) {
      _providers.add(provider);
    }
  }

  /// 📌 **Eliminar un proveedor**
  void removeProvider(String provider) {
    _providers.remove(provider);
  }

  /// 📌 **Limpiar la lista de proveedores**
  void clearData() {
    _providers.clear();
    print("🔹 Datos de proveedores limpiados correctamente");
  }
}
