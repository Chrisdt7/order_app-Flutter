class Order {
  final int id;
  final int id_tables;
  final int? id_users;
  final double total;
  final Status status;
  final Payment payment;

  Order({
    required this.id,
    required this.id_tables,
    this.id_users,
    required this.total,
    required this.status,
    required this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id_orders'],
      id_tables: json['id_tables'],
      id_users: json['id_users'],
      total: json['total'] is int
          ? (json['total'] as int).toDouble()
          : json['total'] is String
              ? double.parse(json['total'])
              : (json['total'] as double),
      status: StatusExtension.fromString(json['status']),
      payment: PaymentExtension.fromString(json['payment']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_orders': id,
      'id_tables': id_tables,
      'id_users': id_users,
      'total': total,
      'status': status.toString().split('.').last,
      'payment': payment.toString().split('.').last,
    };
  }
}

enum Status { Pending, Completed, Canceled, InProgress }

extension StatusExtension on Status {
  static Status fromString(String statusString) {
    switch (statusString) {
      case 'Pending':
        return Status.Pending;
      case 'Completed':
        return Status.Completed;
      case 'Canceled':
        return Status.Canceled;
      case 'In-progress':
        return Status.InProgress;
      default:
        throw Exception('Unknown status: $statusString');
    }
  }
}

enum Payment { Cash, DebitCredit, QR }

extension PaymentExtension on Payment {
  static Payment fromString(String paymentString) {
    switch (paymentString) {
      case 'Cash':
        return Payment.Cash;
      case 'Debit/Credit':
        return Payment.DebitCredit;
      case 'QR':
        return Payment.QR;
      default:
        throw Exception('Unknown payment: $paymentString');
    }
  }
}
