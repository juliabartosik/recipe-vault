import 'package:flutter/material.dart';

class EmptyRecipesView extends StatelessWidget {
  const EmptyRecipesView({super.key, this.filtered = false});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.search_off_rounded : Icons.menu_book_rounded,
              color: const Color(0xFF8FA08A),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              filtered
                  ? 'Brak pasujących przepisów'
                  : 'Nie masz jeszcze przepisów',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Spróbuj innej nazwy lub wybierz inną kategorię.'
                  : 'Dodaj pierwszy przepis w konsoli Firebase.\nWkrótce dodamy formularz administratora.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF71786E)),
            ),
          ],
        ),
      ),
    );
  }
}
