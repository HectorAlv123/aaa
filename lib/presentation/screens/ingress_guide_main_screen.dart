import 'package:flutter/material.dart';
import 'ingress_guide_form_screen.dart';
import 'ingress_guides_database_screen.dart'; // Nueva pantalla con todas las guías

class IngressGuideMainScreen extends StatelessWidget {
  const IngressGuideMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const IngressGuideFormScreen(), // Muestra directamente el formulario
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IngressGuidesDatabaseScreen()),
          );
        },
        child: const Icon(Icons.list), // Ícono de lista para la base de datos
        tooltip: "Ver todas las guías",
      ),
    );
  }
}
