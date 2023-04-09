<h1 align="center">🧪🪿 Goose Test</h1>

<p align="center">
<a href="https://pub.dev/packages/goose_test"><img src="https://img.shields.io/pub/v/goose_test.svg" alt="Pub"></a>
<a href="https://github.com//wolfenrain/goose/actions"><img src="https://github.com/wolfenrain/goose/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com//wolfenrain/goose/actions"><img src="https://raw.githubusercontent.com/wolfenrain/goose/main/coverage_badge.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

A testing library which makes it easy to test migrations. Built to be used with the [Goose migration package](https://pub.dev/packages/goose).

## Installation

Add `goose_test` as a dev dependency to your pubspec.yaml file ([what?](https://flutter.io/using-packages/)).

You can then import Goose Test in your test file:

```dart
import 'package:goose_test/goose_test.dart';
```

## Using `testMigration`

`testMigration` creates a new `migration`-specific test case with the given `description`. `testMigration` will handle running the migration's up and down methods. `testMigration` also ensures that the migration will always happen in the order of `up` first and then try revert through the `down` method to ensure that the migration can be reverted.

| Parameter | Description |
| --------- | ----------- |
| `create`  | Should create and return the `migration` that is to be tested. |
| `setupUp` | An optional callback which is invoked before the `migration`'s `up` is called and can be used for setting up the migration's required data for the `down` migration. For common set up code, prefer to use `setUp` from `package:test/test.dart`. |
| `verifyUp` | An optional callback which is invoked after the `migration`'s `up` was called and can be used for additional verification/assertions. `verifyUp` is called with the `migration` returned by `create`. |
| `setupDown` | An optional callback which is invoked before the `migration`'s `down` is called and can be used for setting up the migration's required data for the `down` migration. For common set up code, prefer to use `setUp` from `package:test/test.dart`. |
| `verifyDown` | An optional callback which is invoked after the `migration`'s `down` was called and can be used for additional verification/assertions. `verifyDown` is called with the `migration` returned by `create`. |
| `tags` | An optional argument and if it is passed, it declares user-defined tags that are applied to the test. These tags can be used to select or skip the test on the command line, or to do bulk test configuration. |

```dart
import 'package:goose_test/goose_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockStorage extends Mock implements Storage {}

void main() {
  group('MyMigration', () {
    late Storage storage;

    setUp(() {
      storage = _MockStorage();
      when(() => storage.clear()).thenAnswer((_) async {});
      when(() => storage.put(any(), any())).thenAnswer((_) async {});
    });

    testMigration(
      'executes correctly',
      create: () => MyMigration(storage),
      verifyUp: (_) {
        verify(() => storage.clear()).called(equals(1));
        verifyNever(() => storage.put(any(), any()));
      },
      verifyDown: (_) => verify(() => storage.clear()).called(equals(1)),
    );
  });
}
