import 'dart:convert';

class BankModel {
  final String id;
  final String name;
  final String accountNumber;
  final String owner;
  final String? logoUrl;
  final bool active;

  BankModel({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.owner,
    this.logoUrl,
    this.active = true,
  });

  BankModel copyWith({
    String? id,
    String? name,
    String? accountNumber,
    String? owner,
    String? logoUrl,
    bool? active,
  }) {
    return BankModel(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      owner: owner ?? this.owner,
      logoUrl: logoUrl ?? this.logoUrl,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'account_number': accountNumber,
      'owner': owner,
      'logo_url': logoUrl,
      'active': active,
    };
  }

  factory BankModel.fromMap(Map<String, dynamic> map) {
    return BankModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      accountNumber: map['account_number'] ?? '',
      owner: map['owner'] ?? '',
      logoUrl: map['logo_url'],
      active: map['active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory BankModel.fromJson(String source) => BankModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BankModel(id: $id, name: $name, accountNumber: $accountNumber, owner: $owner, logoUrl: $logoUrl, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is BankModel &&
      other.id == id &&
      other.name == name &&
      other.accountNumber == accountNumber &&
      other.owner == owner &&
      other.logoUrl == logoUrl &&
      other.active == active;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      accountNumber.hashCode ^
      owner.hashCode ^
      logoUrl.hashCode ^
      active.hashCode;
  }
}
