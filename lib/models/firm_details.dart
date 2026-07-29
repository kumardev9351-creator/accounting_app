class FirmDetails {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String gstin;

  FirmDetails({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.gstin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'gstin': gstin,
    };
  }

  factory FirmDetails.fromMap(Map<String, dynamic> map) {
    return FirmDetails(
      id: map['id'],
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      gstin: map['gstin'] ?? '',
    );
  }
}