class Table {
  final int? id;
  final int? tableNumber;
  final String? tableQr;

  Table({
    this.id,
    this.tableNumber,
    this.tableQr,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id_tables'] as int?,
      tableNumber: json['table_number'] as int?,
      tableQr: json['table_qr'] as String?,
    );
  }
}
