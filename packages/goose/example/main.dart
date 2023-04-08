import 'dart:io';

import 'package:goose/goose.dart';

import 'migrations/migrations.dart';

final state = File('state.txt')..createSync();

void main(List<String> args) async {
  final goose = Goose(
    store: (index) => state.writeAsString('$index'),
    retrieve: () => state.readAsString().then(int.tryParse),
    migrations: [
      InitialMigration(),
      FixingMigration(),
      AnotherMigration(),
    ],
  );

  stdout.writeln('''
Can go up: ${await goose.canUp() ? '✅' : '❌'}
Can go down: ${await goose.canDown() ? '✅' : '❌'}''');

  if (args.isEmpty) return visualize(await goose.getMigrationState());
  stdout.writeln('\x1b7');
  goose.migrations.listen(visualize);

  if (args.first == 'down') {
    return goose.down(to: args.length > 1 ? args[1] : null);
  } else if (args.first == 'up') {
    return goose.up(to: args.length > 1 ? args[1] : null);
  }
  throw UnsupportedError('Unknown command: ${args.first}');
}

void visualize(List<MigrationState> migrations) {
  // clear the terminal
  stdout.write('\x1b8\x1b[0J');
  for (final migration in migrations) {
    if (migration.isMigrated) {
      stdout.writeln('🟩 (${migration.name}) ${migration.description}');
    } else {
      stdout.writeln('⬜️ (${migration.name}) ${migration.description}');
    }
  }
}
