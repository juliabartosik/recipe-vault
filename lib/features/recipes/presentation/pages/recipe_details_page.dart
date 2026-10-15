import 'package:flutter/material.dart';

import '../../../categories/domain/recipe_category.dart';
import '../../domain/recipe.dart';
import '../widgets/recipe_photo.dart';

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({
    super.key,
    required this.recipe,
    required this.categories,
  });

  final Recipe recipe;
  final List<RecipeCategory> categories;

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  final Set<int> _checkedIngredients = {};
  final Set<int> _completedSteps = {};

  void _toggle(Set<int> selected, int index, bool value) {
    setState(() {
      if (value) {
        selected.add(index);
      } else {
        selected.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final theme = Theme.of(context);
    final categoryNames = recipe.categoryIds
        .map((id) => RecipeCategory.nameFor(id, widget.categories))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Przepis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 36),
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: RecipePhoto(url: recipe.imageUrl, borderRadius: 24),
          ),
          const SizedBox(height: 22),
          Text(
            recipe.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (recipe.description != null) ...[
            const SizedBox(height: 8),
            Text(recipe.description!, style: theme.textTheme.bodyLarge),
          ],
          if (categoryNames.isNotEmpty || recipe.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 3,
              children: [
                for (final category in categoryNames)
                  Chip(label: Text(category)),
                for (final tag in recipe.tags)
                  Chip(
                    label: Text('#$tag'),
                    backgroundColor: const Color(0xFFEDF0E7),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
          if (recipe.preparationTime != null || recipe.servings != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (recipe.preparationTime != null) ...[
                  const Icon(Icons.schedule_outlined, size: 19),
                  const SizedBox(width: 5),
                  Text('${recipe.preparationTime} min'),
                ],
                if (recipe.preparationTime != null && recipe.servings != null)
                  const SizedBox(width: 20),
                if (recipe.servings != null) ...[
                  const Icon(Icons.people_outline, size: 19),
                  const SizedBox(width: 5),
                  Text('${recipe.servings} porcje'),
                ],
              ],
            ),
          ],
          const SizedBox(height: 26),
          _SectionHeading(
            title: 'Składniki',
            subtitle: recipe.ingredients.isEmpty
                ? null
                : '${_checkedIngredients.length}/${recipe.ingredients.length} odhaczone',
          ),
          const SizedBox(height: 10),
          if (recipe.ingredients.isEmpty)
            const _MissingSection('Nie dodano jeszcze składników.')
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    for (var i = 0; i < recipe.ingredients.length; i++)
                      CheckboxListTile(
                        value: _checkedIngredients.contains(i),
                        onChanged: (value) =>
                            _toggle(_checkedIngredients, i, value ?? false),
                        title: Text(
                          recipe.ingredients[i],
                          style: TextStyle(
                            decoration: _checkedIngredients.contains(i)
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: _checkedIngredients.contains(i)
                                ? const Color(0xFF899087)
                                : null,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        dense: true,
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 26),
          const _SectionHeading(title: 'Przygotowanie'),
          const SizedBox(height: 10),
          if (recipe.steps.isEmpty)
            const _MissingSection('Nie dodano jeszcze instrukcji.')
          else
            for (var i = 0; i < recipe.steps.length; i++) ...[
              _StepCard(
                number: i + 1,
                text: recipe.steps[i],
                isCompleted: _completedSteps.contains(i),
                onToggle: () =>
                    _toggle(_completedSteps, i, !_completedSteps.contains(i)),
              ),
              const SizedBox(height: 10),
            ],
          if (recipe.nutrition != null) ...[
            const SizedBox(height: 22),
            const _SectionHeading(title: 'Makro'),
            const SizedBox(height: 12),
            _NutritionGrid(nutrition: recipe.nutrition!),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (subtitle != null)
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MissingSection extends StatelessWidget {
  const _MissingSection(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.text,
    required this.isCompleted,
    required this.onToggle,
  });

  final int number;
  final String text;
  final bool isCompleted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: isCompleted
                    ? const Color(0xFF42634B)
                    : const Color(0xFFE7EDE3),
                foregroundColor: isCompleted
                    ? Colors.white
                    : const Color(0xFF42634B),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, size: 19)
                    : Text('$number'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    height: 1.45,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted ? const Color(0xFF899087) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  const _NutritionGrid({required this.nutrition});

  final RecipeNutrition nutrition;

  String _number(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final values = <(String, String)>[
      if (nutrition.kcal != null)
        ('Kalorie', '${_number(nutrition.kcal!)} kcal'),
      if (nutrition.protein != null)
        ('Białko', '${_number(nutrition.protein!)} g'),
      if (nutrition.fat != null) ('Tłuszcz', '${_number(nutrition.fat!)} g'),
      if (nutrition.carbs != null)
        ('Węglowodany', '${_number(nutrition.carbs!)} g'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.25,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final (label, value) = values[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0E6),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF375641),
                ),
              ),
              const SizedBox(height: 3),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
