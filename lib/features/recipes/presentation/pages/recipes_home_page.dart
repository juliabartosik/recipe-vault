import 'package:flutter/material.dart';

import '../../../categories/data/category_repository.dart';
import '../../../categories/domain/recipe_category.dart';
import '../../data/recipe_repository.dart';
import '../../domain/recipe.dart';
import '../widgets/empty_recipes_view.dart';
import '../widgets/recipe_photo.dart';
import 'recipe_details_page.dart';

class RecipesHomePage extends StatefulWidget {
  const RecipesHomePage({super.key});

  @override
  State<RecipesHomePage> createState() => _RecipesHomePageState();
}

class _RecipesHomePageState extends State<RecipesHomePage> {
  final _searchController = TextEditingController();
  final _recipeRepository = RecipeRepository();
  final _categoryRepository = CategoryRepository();

  late final Stream<List<Recipe>> _recipesStream = _recipeRepository
      .watchRecipes();
  late final Stream<List<RecipeCategory>> _categoriesStream =
      _categoryRepository.watchCategories();

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => setState(() {});

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Recipe recipe) {
    final search = _searchController.text.trim().toLowerCase();
    final matchesCategory =
        _selectedCategoryId == null ||
        recipe.categoryIds.contains(_selectedCategoryId);
    final searchable = [
      recipe.title,
      recipe.description ?? '',
      ...recipe.tags,
      ...recipe.ingredients,
    ].join(' ').toLowerCase();
    return matchesCategory && (search.isEmpty || searchable.contains(search));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: StreamBuilder<List<RecipeCategory>>(
            stream: _categoriesStream,
            builder: (context, categorySnapshot) {
              final categories =
                  categorySnapshot.data ?? RecipeCategory.defaults;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipe Vault',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Szukaj przepisu lub składnika...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              tooltip: 'Wyczyść wyszukiwanie',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: _searchController.clear,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Kategorie',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 43,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = index == 0
                            ? null
                            : categories[index - 1];
                        final id = category?.id;
                        final selected = _selectedCategoryId == id;
                        return ChoiceChip(
                          label: Text(category?.name ?? 'Wszystkie'),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) => setState(() {
                            _selectedCategoryId = id;
                          }),
                        );
                      },
                    ),
                  ),
                  if (categorySnapshot.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Nie udało się pobrać kategorii z Firestore. Sprawdź reguły.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<List<Recipe>>(
                      stream: _recipesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Błąd pobierania przepisów. Sprawdź reguły Firestore.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final allRecipes = snapshot.data!;
                        final recipes = allRecipes.where(_matches).toList();
                        final isFiltered =
                            _selectedCategoryId != null ||
                            _searchController.text.trim().isNotEmpty;

                        if (recipes.isEmpty) {
                          return EmptyRecipesView(filtered: isFiltered);
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 28),
                          itemCount: recipes.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Przepisy',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      '${recipes.length} z ${allRecipes.length}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final recipe = recipes[index - 1];
                            return _RecipeListCard(
                              recipe: recipe,
                              categories: categories,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RecipeDetailsPage(
                                    recipe: recipe,
                                    categories: categories,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecipeListCard extends StatelessWidget {
  const _RecipeListCard({
    required this.recipe,
    required this.categories,
    required this.onTap,
  });

  final Recipe recipe;
  final List<RecipeCategory> categories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryLabels = recipe.categoryIds
        .map((id) => RecipeCategory.nameFor(id, categories))
        .join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 92,
                child: RecipePhoto(url: recipe.imageUrl, borderRadius: 13),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (categoryLabels.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        categoryLabels,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (recipe.preparationTime != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.preparationTime} min',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
