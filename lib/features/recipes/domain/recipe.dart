import 'package:cloud_firestore/cloud_firestore.dart';

import '../../categories/domain/recipe_category.dart';

class RecipeNutrition {
  const RecipeNutrition({this.kcal, this.protein, this.fat, this.carbs});

  final double? kcal;
  final double? protein;
  final double? fat;
  final double? carbs;

  bool get hasAnyValue =>
      kcal != null || protein != null || fat != null || carbs != null;

  factory RecipeNutrition.fromMap(Map<String, dynamic>? map) {
    double? number(dynamic raw) => raw is num ? raw.toDouble() : null;

    return RecipeNutrition(
      kcal: number(map?['kcal']),
      protein: number(map?['protein']),
      fat: number(map?['fat']),
      carbs: number(map?['carbs']),
    );
  }
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.categoryIds,
    required this.ingredients,
    required this.steps,
    required this.tags,
    this.description,
    this.imageUrl,
    this.preparationTime,
    this.servings,
    this.createdAt,
    this.nutrition,
  });

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<String> categoryIds;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final int? preparationTime;
  final int? servings;
  final DateTime? createdAt;
  final RecipeNutrition? nutrition;

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    String? optionalText(dynamic value) {
      if (value is! String || value.trim().isEmpty) return null;
      return value.trim();
    }

    List<String> stringList(dynamic value) {
      if (value is! List) return const [];
      return value
          .whereType<String>()
          .map((element) => element.trim())
          .where((element) => element.isNotEmpty)
          .toList();
    }

    int? positiveInt(dynamic value) {
      if (value is! num || value <= 0) return null;
      return value.toInt();
    }

    final storedCategoryIds = stringList(map['categoryIds']);
    final legacyCategory = RecipeCategory.idForLegacyName(
      optionalText(map['category']),
    );
    final categoryIds = storedCategoryIds.isNotEmpty
        ? storedCategoryIds
        : (legacyCategory == null ? <String>[] : <String>[legacyCategory]);

    final nutritionMap = map['nutrition'];
    final nutrition = RecipeNutrition.fromMap(
      nutritionMap is Map<String, dynamic> ? nutritionMap : null,
    );
    final timestamp = map['createdAt'];

    return Recipe(
      id: id,
      title: optionalText(map['title']) ?? 'Bez nazwy',
      description: optionalText(map['description']),
      imageUrl: optionalText(map['imageUrl']),
      categoryIds: categoryIds,
      ingredients: stringList(map['ingredients']),
      steps: stringList(map['steps']),
      tags: stringList(map['tags']),
      preparationTime: positiveInt(map['preparationTime']),
      servings: positiveInt(map['servings']),
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
      nutrition: nutrition.hasAnyValue ? nutrition : null,
    );
  }
}
