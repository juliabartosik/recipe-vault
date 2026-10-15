import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_vault/features/recipes/domain/recipe.dart';

void main() {
  test('rozpoznaje starszą kategorię Obiad', () {
    final recipe = Recipe.fromMap('test', {
      'title': 'Spaghetti carbonara',
      'category': 'Obiad',
    });

    expect(recipe.title, 'Spaghetti carbonara');
    expect(recipe.categoryIds, ['lunch']);
    expect(recipe.ingredients, isEmpty);
    expect(recipe.nutrition, isNull);
  });

  test('wczytuje składniki, kroki i wartości odżywcze', () {
    final recipe = Recipe.fromMap('omlet', {
      'title': 'Omlet bananowy',
      'categoryIds': ['breakfast', 'dessert'],
      'ingredients': ['Banan', 'Jajko'],
      'steps': ['Wymieszaj', 'Usmaż'],
      'nutrition': {'kcal': 452, 'protein': 30, 'fat': 13, 'carbs': 55},
    });

    expect(recipe.categoryIds, ['breakfast', 'dessert']);
    expect(recipe.steps.length, 2);
    expect(recipe.nutrition?.kcal, 452);
  });
}
