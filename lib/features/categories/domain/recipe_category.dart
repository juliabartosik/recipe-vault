class RecipeCategory {
  const RecipeCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.iconKey = 'restaurant',
  });

  final String id;
  final String name;
  final int sortOrder;
  final String iconKey;

  factory RecipeCategory.fromFirestore(String id, Map<String, dynamic> data) {
    return RecipeCategory(
      id: id,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : id,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 100,
      iconKey: data['iconKey'] is String
          ? data['iconKey'] as String
          : 'restaurant',
    );
  }

  // Startowe kategorie widoczne również przed dodaniem dokumentów w Firestore.
  // Dokument w kolekcji categories o tym samym ID nadpisuje nazwę/kolejność.
  static const defaults = <RecipeCategory>[
    RecipeCategory(
      id: 'breakfast',
      name: 'Śniadania',
      sortOrder: 0,
      iconKey: 'breakfast',
    ),
    RecipeCategory(id: 'lunch', name: 'Obiady', sortOrder: 1, iconKey: 'lunch'),
    RecipeCategory(
      id: 'dinner',
      name: 'Kolacje',
      sortOrder: 2,
      iconKey: 'dinner',
    ),
    RecipeCategory(
      id: 'dessert',
      name: 'Desery',
      sortOrder: 3,
      iconKey: 'dessert',
    ),
    RecipeCategory(
      id: 'snacks',
      name: 'Przekąski',
      sortOrder: 4,
      iconKey: 'snacks',
    ),
    RecipeCategory(
      id: 'drinks',
      name: 'Napoje',
      sortOrder: 5,
      iconKey: 'drinks',
    ),
  ];

  static String? idForLegacyName(String? name) {
    switch (name?.trim().toLowerCase()) {
      case 'śniadanie':
      case 'śniadania':
        return 'breakfast';
      case 'obiad':
      case 'obiady':
        return 'lunch';
      case 'kolacja':
      case 'kolacje':
        return 'dinner';
      case 'deser':
      case 'desery':
        return 'dessert';
      case 'przekąska':
      case 'przekąski':
        return 'snacks';
      case 'napój':
      case 'napoje':
        return 'drinks';
      default:
        return null;
    }
  }

  static String nameFor(String id, List<RecipeCategory> categories) {
    for (final category in categories) {
      if (category.id == id) return category.name;
    }
    return id;
  }
}
