import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/recipe_category.dart';

class CategoryRepository {
  CategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<RecipeCategory>> watchCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      final categories = <String, RecipeCategory>{
        for (final category in RecipeCategory.defaults) category.id: category,
      };

      for (final doc in snapshot.docs) {
        categories[doc.id] = RecipeCategory.fromFirestore(doc.id, doc.data());
      }

      return categories.values.toList()..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
      });
    });
  }
}
