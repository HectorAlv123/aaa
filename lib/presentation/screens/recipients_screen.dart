import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/recipient_manager.dart';

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({Key? key}) : super(key: key);

  @override
  _RecipientsScreenState createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  List<String> recipients = List.from(RecipientManager.instance.recipients);
  final TextEditingController _recipientController = TextEditingController();

  /// 🔹 Agregar un nuevo destinatario
  void _addRecipient() {
    String recipient = _recipientController.text.trim();
    if (recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un destinatario válido'))
      );
      return;
    }

    setState(() {
      recipients.add(recipient);
      RecipientManager.instance.addRecipient(recipient);
      _recipientController.clear();
    });

    Navigator.pop(context);
  }

  /// 🔹 Eliminar destinatario
  void _removeRecipient(int index) {
    setState(() {
      recipients.removeAt(index);
    });
  }

  /// 🔹 Mostrar diálogo para agregar destinatario
  void _showAddRecipientDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Destinatario"),
          content: TextField(
            controller: _recipientController,
            decoration: const InputDecoration(labelText: "Nombre del Destinatario"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: _addRecipient,
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar Destinatario")),
      body: recipients.isEmpty
          ? const Center(child: Text("No hay destinatarios registrados"))
          : ListView.builder(
              itemCount: recipients.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recipients[index]),
                  onTap: () {
                    Navigator.pop(context, recipients[index]); // ✅ Devuelve el destinatario seleccionado
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeRecipient(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecipientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
