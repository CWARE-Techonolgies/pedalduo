class CourtItem {
  final String name;
  final String location;
  final int courts;

  CourtItem({
    required this.name,
    required this.location,
    required this.courts,
  });

  // Convert from JSON
  factory CourtItem.fromJson(Map<String, dynamic> json) {
    return CourtItem(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      courts: json['courts'] ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'courts': courts,
    };
  }

  // Copy with method for updating properties
  CourtItem copyWith({
    String? name,
    String? location,
    int? courts,
  }) {
    return CourtItem(
      name: name ?? this.name,
      location: location ?? this.location,
      courts: courts ?? this.courts,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourtItem &&
        other.name == name &&
        other.location == location &&
        other.courts == courts;
  }

  @override
  int get hashCode => name.hashCode ^ location.hashCode ^ courts.hashCode;

  @override
  String toString() {
    return 'CourtItem(name: $name, location: $location, courts: $courts)';
  }
}