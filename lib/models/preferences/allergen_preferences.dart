import 'user_preferences.dart';

import '../allergen.dart';

class Allergies {

  final List<Allergen> allergies;
  Allergies({required this.allergies});

  factory Allergies.fromJson(Map<String, dynamic> json) {
    return Allergies(
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => Allergen(id: e['id'], name: e['name']))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies.map((e) => {'id': e.id, 'name': e.name}).toList(),
    };
  }
}