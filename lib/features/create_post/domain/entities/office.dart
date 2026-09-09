class Office {
  const Office({
    required this.id,
    required this.name,
    this.city = '',
    this.state = '',
    this.address = '',
  });

  final int id;
  final String name;
  final String city;
  final String state;
  final String address;

  String get locationLabel {
    final List<String> parts = <String>[
      if (city.trim().isNotEmpty) city.trim(),
      if (state.trim().isNotEmpty) state.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    if (address.trim().isNotEmpty) return address.trim();
    return '';
  }
}
