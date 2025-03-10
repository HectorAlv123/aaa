// lib/managers/order_manager.dart
import 'package:inventario_app/data/models/order.dart';


class OrderManager {
  OrderManager._privateConstructor();
  static final OrderManager instance = OrderManager._privateConstructor();

  final List<Order> _orders = [];
  Order? pendingOrder;

  List<Order> get orders => _orders;

  void addOrder(Order order) {
    if (!order.isFinalized) {
      pendingOrder = order;
    }
    _orders.add(order);
  }

  void removeOrder(Order order) {
    _orders.remove(order);
    if (pendingOrder == order) {
      pendingOrder = null;
    }
  }

  void clearPendingOrder() {
    pendingOrder = null;
  }
}
