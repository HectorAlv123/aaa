class DispatchVoucher {
  final String id;
  final DateTime date;
  final String receiver;
  final List<VoucherItem> items;

  DispatchVoucher({
    required this.id,
    required this.date,
    required this.receiver,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'receiver': receiver,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory DispatchVoucher.fromJson(Map<String, dynamic> json) {
    return DispatchVoucher(
      id: json['id'],
      date: DateTime.parse(json['date']),
      receiver: json['receiver'],
      items: (json['items'] as List).map((item) => VoucherItem.fromJson(item)).toList(),
    );
  }
}

class VoucherItem {
  final String productId;
  final String description;
  final int quantity;

  VoucherItem({
    required this.productId,
    required this.description,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'description': description,
      'quantity': quantity,
    };
  }

  factory VoucherItem.fromJson(Map<String, dynamic> json) {
    return VoucherItem(
      productId: json['productId'],
      description: json['description'],
      quantity: json['quantity'],
    );
  }
}
