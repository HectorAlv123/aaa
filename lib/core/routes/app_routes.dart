import 'package:flutter/material.dart';
import 'package:inventario_app/presentation/screens/product_list_screen.dart';
import 'package:inventario_app/presentation/screens/login_screen.dart';
import 'package:inventario_app/presentation/screens/transfer_screen.dart';
import 'package:inventario_app/presentation/screens/category_screen.dart';
import 'package:inventario_app/presentation/screens/order_screen.dart';
import 'package:inventario_app/presentation/screens/dispatch_voucher_list_screen.dart';
import 'package:inventario_app/presentation/screens/home_screen.dart';
import 'package:inventario_app/presentation/screens/data_management_screen.dart';
import 'package:inventario_app/presentation/screens/ingress_guide_main_screen.dart';
import 'package:inventario_app/presentation/screens/vehicle_plates_screen.dart';
import 'package:inventario_app/presentation/screens/drivers_screen.dart';
import 'package:inventario_app/presentation/screens/recipients_screen.dart';
import 'package:inventario_app/presentation/screens/providers_screen.dart';
import 'package:inventario_app/presentation/screens/add_dispatch_voucher_screen.dart';
import 'package:inventario_app/presentation/screens/statistics_screen.dart';
import 'package:inventario_app/presentation/screens/product_variation_screen.dart';

class AppRoutes {
  static const String login = "/login";
  static const String home = "/home";
  static const String inventory = "/inventory";
  static const String transfer = "/transfer";
  static const String categories = "/categories";
  static const String order = "/order";
  static const String addDispatchVoucher = "/addDispatchVoucher";
  static const String dispatchVouchers = "/dispatchVouchers";
  static const String data = "/data";
  static const String ingressGuides = "/ingressGuides";
  static const String vehiclePlates = "/vehiclePlates";
  static const String drivers = "/drivers";
  static const String providers = "/providers";
  static const String recipients = "/recipients";
  static const String statistics = '/statistics';
  static const String productVariation = '/productVariation';

  static Map<String, Widget Function(BuildContext)> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    inventory: (context) => ProductListScreen(isAdmin: true, warehouse: "18B"),
    transfer: (context) => const TransferScreen(),
    categories: (context) => const CategoryScreen(),
    order: (context) => OrderScreen(guiaIngreso: "Número de Guía"),
    addDispatchVoucher: (context) => const AddDispatchVoucherScreen(),
    dispatchVouchers: (context) => const DispatchVoucherListScreen(),
    data: (context) => const DataManagementScreen(),
    ingressGuides: (context) => const IngressGuideMainScreen(),
    vehiclePlates: (context) => const VehiclePlatesScreen(),
    drivers: (context) => const DriversScreen(),
    providers: (context) => const ProvidersScreen(),
    recipients: (context) => const RecipientsScreen(),
     AppRoutes.statistics: (context) => const StatisticsScreen(),
  AppRoutes.productVariation: (context) => const ProductVariationScreen(),
  };
}