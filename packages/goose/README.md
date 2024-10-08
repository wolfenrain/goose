<h1 align="center">🪿 Goose</h1>

<p align="center">
<a href="https://pub.dev/packages/goose"><img src="https://img.shields.io/pub/v/goose.svg" alt="Pub"></a>
<a href="https://github.com//wolfenrain/goose/actions"><img src="https://github.com/wolfenrain/goose/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com//wolfenrain/goose/actions"><img src="https://raw.githubusercontent.com/wolfenrain/goose/main/coverage_badge.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

Just as geese migrate, you too can migrate your code with the help of Goose.

---

Goose is a minimalistic migration framework that has no opinions on how you should migrate, it only provides a structure to do so.

You can use Goose wherever you want, with whatever you want. Whether that's [Flutter](https://flutter.dev) with [Isar](https://isar.dev) or [Dart Frog](https://dartfrog.vgv.dev) with [Hive](https://pub.dev/packages/hive) or X with Y, this silly goose can do it all!

It comes with the following features:

- 🚀 Migrating up or down using a programmable API
- 🧑‍💻 Platform agnostic, use any database or system you prefer
- 🙅 Zero dependencies and therefore zero headaches
- 🪿 A silly Goose

## Installation

Add `goose` as a dependency to your pubspec.yaml file ([what?](https://flutter.io/using-packages/)).

You can then import Goose:

```dart
import 'package:goose/goose.dart';
```

## Usage

You can start using Goose by creating an instance of a `Goose`, defining how you are going to store 
the migration key and of course your migrations:

```dart
import 'package:goose/goose.dart';

class MyMigration extends Migration {
  const MyMigration() : super('my_unique_migration_id', description: 'My optional description');

  /// Called when this migration is being reverted.
  Future<void> down() async {
    ...
  }

  /// Called when this migration is being applied.
  Future<void> up() async {
    ...
  }
}

void main() async {
  // We are just storing the key in-memory, but normally you would store this in a database for 
  // persistence.
  int? migrationKey;

  final goose = Goose(
    // Called whenever Goose needs the current migration key.
    retrieve: () async => migrationKey,
    // Called whenever Goose wants to store the next migration key.
    store: (key) async => migrationKey = key,
    // List of all the migrations that Goose has to handle.
    migrations: const [
      MyMigration(),
      ...
    ],
  );

  // Migrate all the way up through all our migrations.
  await goose.up();

  // Migrate all the way down through all our migrations.
  await goose.down();
}
```

### Migrating up and down to a certain migration

In the above example we called `goose.up` to migrate all the way up but you can also pass a `migration id` to migrate up that given migration:

```dart
void main() {
  final goose = Goose(
    retrieve: () async => ...
    store: (key) async => ...,
    migrations: const [
      MyMigration(),
      ...
    ],
  );

  // This will migrate up to that specific migration.
  await goose.up(to: 'my_specific_migration');
}
```

The same can be done with the `down`, but keep in mind that the migration you specify won't be migrated down.

If you want to check if there is something to go up or down to you can use the `canUp` and `canDown` methods:


```dart
void main() {
  final goose = Goose(
    retrieve: () async => ...
    store: (key) async => ...,
    migrations: const [
      MyMigration(),
      ...
    ],
  );

  // This will migrate up to that specific migration.
  await goose.up(to: 'my_specific_migration');
  if (await goose.canUp()) {
    // Still more to migrate.
    ...
  }
}
```

### Listening to migration state changes

We can also listen to changes to the migration state:

```dart
void main() {
  final goose = Goose(
    retrieve: () async => ...
    store: (key) async => ...,
    migrations: const [
      MyMigration(),
      ...
    ],
  );

  /// For each migration being migrated up or down, the migrations stream will be triggered.
  goose.migrations.listen((migrations) {
    for (final migration in migrations) {
      print('${migration.name} has the description "${migration.description}" and is ${migration.isMigrated ? 'migrated' : 'not migrated'}');
    }
  })

  await goose.up();
}
```

And if you want to retrieve the current state of the migrations:

```dart
void main() {
  final goose = Goose(
    retrieve: () async => ...
    store: (key) async => ...,
    migrations: const [
      MyMigration(),
      ...
    ],
  );

  final previousState = await goose.getMigrationState();
  await goose.up();
  final currentState = await goose.getMigrationState();

  ...
}
```
