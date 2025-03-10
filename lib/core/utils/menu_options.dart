import 'package:flutter/material.dart';

class MenuOptions {
  static final List<Map<String, dynamic>> options = [
    {"title": "Inventario", "icon": Icons.inventory, "color": Colors.blue, "route": "/inventory"},
    {"title": "Transferencias", "icon": Icons.sync_alt, "color": Colors.orange, "route": "/transfer"},
    {"title": "Categorías", "icon": Icons.category, "color": Colors.green, "route": "/categories"},
    {"title": "Pedido con Guía", "icon": Icons.assignment, "color": Colors.purple, "route": "/order"},
    {"title": "Vales de Salida", "icon": Icons.receipt_long, "color": Colors.teal, "route": "/dispatchVouchers"},
  ];
}
