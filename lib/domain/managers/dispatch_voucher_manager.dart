import 'package:inventario_app/data/models/dispatch_voucher.dart';
import 'package:collection/collection.dart';

class DispatchVoucherManager {
  static final DispatchVoucherManager instance = DispatchVoucherManager();
  final List<DispatchVoucher> _vouchers = [];

  List<DispatchVoucher> get vouchers => List.unmodifiable(_vouchers);

  /// 🔹 Agrega un vale de despacho al listado
  void addVoucher(DispatchVoucher voucher) {
    _vouchers.add(voucher);
  }

  /// 🔹 Obtiene un vale de despacho por ID, retorna `null` si no existe
  DispatchVoucher? getVoucherById(String id) {
    return _vouchers.firstWhereOrNull((voucher) => voucher.id == id);
  }
}
