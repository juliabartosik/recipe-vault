import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_vault/features/recipes/presentation/widgets/empty_recipes_view.dart';

void main() {
  testWidgets('pusty ekran pokazuje właściwy komunikat', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyRecipesView())),
    );

    expect(find.text('Nie masz jeszcze przepisów'), findsOneWidget);
  });
}
