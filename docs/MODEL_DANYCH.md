# Model danych Firestore — etap 1

## `recipes/{recipeId}`

| Pole | Typ | Wymagane | Opis |
|---|---|---|---|
| `title` | string | tak | Nazwa potrawy |
| `description` | string | nie | Krótki opis |
| `categoryIds` | array<string> | zalecane | Stałe identyfikatory, np. `["breakfast", "dessert"]` |
| `tags` | array<string> | nie | Opcjonalne oznaczenia, np. `wysokobiałkowe` |
| `imageUrl` | string | nie | Pełny adres HTTPS do zdjęcia |
| `ingredients` | array<string> | nie | Jeden punkt listy = jeden napis |
| `steps` | array<string> | nie | Kolejność przygotowania = kolejność w tablicy |
| `servings` | number | nie | Liczba porcji (tylko dodatnia) |
| `preparationTime` | number | nie | Czas w minutach (tylko dodatni) |
| `nutrition` | map | nie | `kcal`, `protein`, `fat`, `carbs` jako numbers |
| `createdAt` | timestamp | nie | Sortowanie najnowszych przed starszymi |

Wartości makro domyślnie interpretujemy jako dane przekazane przez autora dla przepisu, a nie automatycznie jako „na 100 g”. Docelowo dodamy jawne oznaczenie, czy dotyczą jednej porcji, całej potrawy, czy 100 g.

Dla kompatybilności czytnik wspiera też starsze pole `category: "Obiad"` — mapuje je na `categoryIds: ["lunch"]`, gdy `categoryIds` nie istnieje.

**Uwaga:** składniki jako tekst są łatwe do wpisania, ale nie pozwalają bezpiecznie automatycznie przeliczać porcji. W późniejszym etapie dodamy model z ilością, jednostką i opcjonalnym zamiennikiem, zachowując możliwość dowolnych uwag.

## `categories/{categoryId}`

| Pole | Typ | Opis |
|---|---|---|
| `name` | string | Nazwa prezentowana użytkownikowi |
| `sortOrder` | number | Kolejność w pasku kategorii |
| `iconKey` | string | Zarezerwowane pod przyszłe ikony kategorii |

Stałe identyfikatory bazowe: `breakfast`, `lunch`, `dinner`, `dessert`, `snacks`, `drinks`.

Nie zapisujemy nazw kategorii bezpośrednio do przepisów — tylko ich identyfikatory. Zmiana nazwy kategorii nie wymaga edycji wszystkich przepisów.

## Ograniczenia etapu 1

- Filtrujemy listę po stronie Fluttera. To rozsądne dla prywatnej bazy kilkudziesięciu/kilkuset przepisów, ale przy tysiącach należy rozważyć paginację i indeksy.
- W kategorii można mieć wiele przepisów; jeden przepis może należeć do wielu kategorii.
- Sześć kategorii bazowych jest dostępne jako fallback w aplikacji, dokumenty Firestore mogą je nadpisać.
- Wszystkie przepisy są publiczne do odczytu na poziomie Firestore Rules.
