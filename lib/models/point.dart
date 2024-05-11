class Point{
  int value = 0;

  Point({
    this.value = 0,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}