class PostLocation {
  const PostLocation({
    required this.label,
    this.address = '',
    this.latitude,
    this.longitude,
  });

  final String label;
  final String address;
  final double? latitude;
  final double? longitude;

  String get displaySubtitle {
    if (address.trim().isNotEmpty) return address.trim();
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
    }
    return '';
  }
}
