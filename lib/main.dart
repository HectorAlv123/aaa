import 'package:flutter/material.dart';
import 'package:inventario_app/core/routes/app_routes.dart'; // ✅ Asegúrate de importar correctamente AppRoutes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home', // ✅ Asegúrate de que la ruta inicial es correcta
      routes: AppRoutes.routes, // ✅ Usa las rutas definidas en AppRoutes
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text("Ruta no encontrada")),
        ),
      ),
    );
  }
}
