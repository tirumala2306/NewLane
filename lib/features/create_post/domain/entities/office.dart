class Office {
  const Office({
    required this.id,
    required this.name,
    this.city = '',
    this.state = '',
    this.address = '',
    this.phone = '',
    this.email = '',
  });

  final int id;
  final String name;
  final String city;
  final String state;
  final String address;
  final String phone;
  final String email;

  String get locationLabel {
    final List<String> parts = <String>[
      if (city.trim().isNotEmpty) city.trim(),
      if (state.trim().isNotEmpty) state.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    if (address.trim().isNotEmpty) return address.trim();
    return '';
  }

  String get displayAddress {
    if (address.trim().isNotEmpty) return address.trim();
    return locationLabel;
  }
}
