import 'user_preferences.dart';
import '../recipe.dart';

class Recipes  {
  final List<Recipe> recipes;

  Recipes({required this.recipes});

  factory Recipes.fromJson(Map<String, dynamic> json) {
    return Recipes(
      recipes: (json['recipes'] as List<dynamic>?)
          ?.map((e) => Recipe(userId: e['user_id'], title: e['title'], content: e['content'],
      )).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipes': recipes.map((e) => {
        'user_id': e.userId,
        'title': e.title,
        'content': e.content,
      }).toList(),
    };
  }
}