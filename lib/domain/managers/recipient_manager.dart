// lib/domain/managers/recipient_manager.dart
class RecipientManager {
  static final RecipientManager instance = RecipientManager._internal();
  RecipientManager._internal();

  final Set<String> _recipients = {"Juan Pérez", "María Gómez", "Carlos Sánchez"};

  List<String> get recipients => _recipients.toList();

  void addRecipient(String recipient) {
    if (recipient.isNotEmpty) {
      _recipients.add(recipient);
    }
  }

  void clearData() {
    _recipients.clear();
    print("Datos de destinatarios limpiados");
  }
}
