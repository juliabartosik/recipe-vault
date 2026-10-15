# Recipe Vault — wdrożenie pierwszej wersji

Ta paczka zawiera **kod źródłowy**, który wklejasz do swojego istniejącego projektu Flutter (`D:\recipe-vault`). Nie jest osobnym projektem Flutter.

## 0. Zabezpiecz działającą wersję

W istniejącym projekcie wykonaj:

```powershell
cd D:\recipe-vault
git status
# Jeśli masz niezapisane zmiany, najpierw sprawdź je i wykonaj commit.
git switch -c feature/recipes-categories
```

Jeśli już pracujesz na branchu, nie musisz tworzyć go ponownie.

## 1. Skopiuj pliki

Rozpakuj ZIP. Skopiuj folder `lib` z paczki do katalogu głównego swojego projektu, **scalając foldery**, a nie usuwając istniejący folder `lib`.

- Zastąp `lib/main.dart`.
- Dodaj foldery `lib/app`, `lib/features/...`.
- **Zachowaj istniejący `lib/firebase_options.dart`**, wygenerowany przez `flutterfire configure` (w paczce celowo go nie ma).
- Skopiuj pliki `test/` (stary `test/widget_test.dart` zastąp wersją z paczki; oryginalny test licznika Fluttera nie pasuje już do nowej aplikacji).
- Skopiuj `firestore.rules` do głównego folderu projektu (żeby reguły były wersjonowane w Git).

**Nie nadpisuj** plików `android/settings.gradle.kts`, `android/app/build.gradle.kts`, `android/gradle.properties`, `.gitignore`, `pubspec.yaml` ani `firebase_options.dart` — ich aktualna konfiguracja działa.

## 2. Zależności

W katalogu projektu:

```powershell
flutter pub add firebase_core cloud_firestore firebase_auth
flutter pub get
```

Te zależności prawdopodobnie są już zainstalowane. Nie potrzebujesz dodatkowych bibliotek UI.

## 3. Reguły bezpieczeństwa

Firebase Console → Firestore Database → Rules. Wklej zawartość `firestore.rules` i kliknij **Publish**.

W tym etapie czytanie `recipes` i `categories` jest otwarte bez logowania, a zapis z klienta wyłączony. Możesz nadal ręcznie dodawać dokumenty w konsoli Firebase (konsola działa na uprawnieniach właściciela projektu).

**UWAGA:** Reguła `allow read: if true` to PUBLICZNY odczyt, a nie tylko odczyt dla znajomych z aplikacją. Nie przechowuj poufnych danych w tych kolekcjach.

Później zastąpimy `allow write: if false` autoryzacją administratora po UID, przy tworzeniu ekranu logowania i formularza.

## 4. Dane testowe

Stary dokument `recipes/<ID>` z polami `title: "Spaghetti carbonara"` i `category: "Obiad"` powinien nadal wyświetlać się na liście. Nowy kod automatycznie mapuje stary `category` na `lunch`.

Aby zobaczyć szczegóły omletu, w Firebase Console → Firestore Database → Data → `recipes` → Add document utwórz dokument `omlet-bananowy`. W konsoli Firebase dodawaj wartości polami (plik JSON z paczki służy jako wzór danych; nie można go po prostu wkleić w okno edycji pól konsoli Firestore):

- `title` (string): `Omlet bananowy`
- `description` (string): `Puszysty omlet z gorzką czekoladą`
- `categoryIds` (array): dwa elementy typu string: `breakfast`, `dessert`
- `ingredients` (array): elementy typu string — patrz `docs/PRZYKLADOWY_OMLET.json`
- `steps` (array): elementy typu string — patrz `docs/PRZYKLADOWY_OMLET.json`
- `nutrition` (map): `kcal` 452, `protein` 30, `fat` 13, `carbs` 55 (wszystkie number)
- `servings` (number): 1 **tylko jeśli to jedna porcja** (jeśli nie wiesz — pomiń to pole)
- `imageUrl` (string, opcjonalne): publiczny adres https do zdjęcia

Możesz na początek dodać tylko nazwę i dwie kategorie, a składniki oraz kroki uzupełnić później.

Domyślne kategorie pokażą się bez dodatkowych dokumentów. Jeśli chcesz zmienić ich nazwy lub dodać nowe, utwórz dokumenty w kolekcji `categories`, np.:

| ID dokumentu | `name` (string) | `sortOrder` (number) |
|---|---|---|
| breakfast | Śniadania | 0 |
| lunch | Obiady | 1 |
| dinner | Kolacje | 2 |
| dessert | Desery | 3 |
| snacks | Przekąski | 4 |
| drinks | Napoje | 5 |

Możesz też stworzyć kategorię `soups` z `name: Zupy` i `sortOrder: 6` — pojawi się automatycznie. Uwaga: w tej wersji 6 kategorii domyślnych zawsze istnieje jako fallback; pełne zarządzanie usuwaniem kategorii dodamy w panelu administratora.

## 5. Uruchomienie i testy

```powershell
cd D:\recipe-vault
dart format lib test
flutter analyze
flutter test
flutter run
```

Pierwsze uruchomienie może być wolniejsze przez pobieranie Gradle.

Sprawdź:

1. Lista pokazuje Carbonarę lub inny wcześniej dodany przepis.
2. `Śniadania`, `Obiady`, `Kolacje`, `Desery`, `Przekąski`, `Napoje` są widoczne na pasku.
3. Kliknięcie w `Obiady` pokazuje carbonarę (również ze starym polem `category`).
4. Wyszukiwarka filtruje po tytule, opisie, tagach i składnikach.
5. Dotknięcie przepisu otwiera szczegóły.
6. Odhaczenie składnika i kroku działa tylko lokalnie i nie zmienia dokumentu w Firestore.
7. Gdy edytujesz tytuł przepisu w konsoli Firebase, lista aktualizuje się automatycznie.

## 6. Git — zapisujemy ukończony etap

```powershell
git status
git add lib test firestore.rules docs
git commit -m "feat: add recipe categories, search and details screen"
git push -u origin feature/recipes-categories
```

Uwaga: folder `docs` z paczki także trzeba przenieść do repozytorium, jeśli chcesz zachować dokumentację w Git. Możesz następnie otworzyć Pull Request do `main`.

## 7. Co świadomie zostawiamy na kolejne etapy?

- Ekran logowania i uprawnienia administratora do zapisu.
- Formularz dodawania/edycji/usuwania przepisów.
- Bezpieczny upload zdjęć do osobnego magazynu (np. Cloudinary): **nie** umieszczamy sekretów API w aplikacji.
- Pełne dodawanie/edycja/usuwanie kategorii w aplikacji.
- Automatyczne przeliczanie ilości składników przy zmianie porcji.
- Testy integracyjne Firestore i widoków z backendem.

W tej wersji `imageUrl` umożliwia wyświetlenie zdjęcia, o ile URL jest już dostępny. Firebase Spark nie udostępnia Cloud Storage for Firebase bez planu Blaze.
