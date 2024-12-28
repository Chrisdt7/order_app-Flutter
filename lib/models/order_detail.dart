class OrderDetail {
  final int id;
  int id_orders;
  final int id_menus;
  int quantity;
  String? note;
  double subtotal;

  OrderDetail({
    required this.id,
    required this.id_orders,
    required this.id_menus,
    required this.quantity,
    this.note,
    required this.subtotal,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id_order_details'],
      id_orders: json['id_orders'],
      id_menus: json['id_menus'],
      quantity: json['quantity'],
      note: json['note'],
      subtotal: json['subtotal'] is int
          ? (json['subtotal'] as int).toDouble()
          : json['subtotal'] is String
              ? double.parse(json['subtotal'])
              : (json['subtotal'] as double),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_order_details': id,
      'id_orders': id_orders,
      'id_menus': id_menus,
      'quantity': quantity,
      'note': note,
      'subtotal': subtotal,
    };
  }
}
