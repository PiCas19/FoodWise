import 'recipe_preferences.dart';
import 'allergen_preferences.dart';
import '../point.dart';

class UserPreferences {
  final Allergies allergies;
  final Recipes recipes;
  final Point points;

  UserPreferences({required this.allergies, required this.recipes, required this.points});

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      allergies: Allergies.fromJson(json['allergies']),
      recipes: Recipes.fromJson(json['recipes']),
      points: Point.fromJson(json['points']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies.toJson(),
      'recipes': recipes.toJson(),
      'points': points.toJson(),
    };
  }

}