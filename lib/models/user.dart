class User {
  final int? id;
  final String? name;
  final String? username;
  final String? email;
  final String? role;
  final String? phone;
  final String? address;
  final String? password;

  User({
    this.id,
    this.name,
    this.username,
    this.email,
    this.role,
    this.phone,
    this.address,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Parsing User from JSON: $json'); // Debug statement
    return User(
      id: json['id_users'] as int?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_users': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'password': password,
    };
  }
}
