import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/recipe.dart';

class RecipeRepository {
  RecipeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Recipe>> watchRecipes() {
    // Bez orderBy: stare dokumenty bez createdAt pozostaną widoczne.
    // Sortowanie i filtrowanie odbywa się lokalnie, co wystarczy na start.
    return _firestore.collection('recipes').snapshots().map((snapshot) {
      final recipes = snapshot.docs
          .map((doc) => Recipe.fromMap(doc.id, doc.data()))
          .toList();

      recipes.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          final byDate = b.createdAt!.compareTo(a.createdAt!);
          if (byDate != 0) return byDate;
        } else if (a.createdAt != null) {
          return -1;
        } else if (b.createdAt != null) {
          return 1;
        }
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

      return recipes;
    });
  }
}
