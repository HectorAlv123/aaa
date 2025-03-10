class DispatchNote {
  final String id;
  final String destination;
  final DateTime date;
  final List<DispatchItem> items;

  DispatchNote({
    required this.id,
    required this.destination,
    required this.date,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory DispatchNote.fromMap(Map<String, dynamic> map) {
    return DispatchNote(
      id: map['id'],
      destination: map['destination'],
      date: DateTime.parse(map['date']),
      items: (map['items'] as List).map((item) => DispatchItem.fromMap(item)).toList(),
    );
  }
}

class DispatchItem {
  final String productId;
  final String productName;
  final int quantity;

  DispatchItem({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
    };
  }

  factory DispatchItem.fromMap(Map<String, dynamic> map) {
    return DispatchItem(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
    );
  }
}
