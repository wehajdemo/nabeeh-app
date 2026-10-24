import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/export/application/export_service.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/entitlement_cache.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';

import '../../support/fake_file_sharer.dart';
import '../../support/test_overrides.dart';

ProviderContainer makeContainer(
  FakeFileSharer sharer, {
  bool plus = true,
  bool demo = true,
}) {
  final container = ProviderContainer(
    overrides: [
      fixedClock(),
      if (demo) demoStore() else emptyStore(),
      fileSharerProvider.overrideWithValue(sharer),
      reportFontsProvider.overrideWithValue(fontsFromDisk),
      entitlementCacheProvider.overrideWithValue(
        MemoryEntitlementCache(
          plus
              ? PlusEntitlement(
                  active: true,
                  expiresAt: testNow.add(const Duration(days: 20)),
                )
              : null,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('free users cannot export', () async {
    final sharer = FakeFileSharer();
    final container = makeContainer(sharer, plus: false);

    await expectLater(
      container.read(exportServiceProvider).export(ExportFormat.csv),
      throwsA(isA<PlusRequiredException>()),
    );
    expect(sharer.shared, isEmpty);
  });

  test('an expired subscription cannot export', () async {
    final sharer = FakeFileSharer();
    final container = ProviderContainer(
      overrides: [
        fixedClock(),
        demoStore(),
        fileSharerProvider.overrideWithValue(sharer),
        entitlementCacheProvider.overrideWithValue(
          MemoryEntitlementCache(
            PlusEntitlement(
              active: true,
              expiresAt: testNow.subtract(const Duration(days: 1)),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(exportServiceProvider).export(ExportFormat.pdf),
      throwsA(isA<PlusRequiredException>()),
    );
  });

  test('Plus users get a CSV of this cycle\'s expenses', () async {
    final sharer = FakeFileSharer();
    final container = makeContainer(sharer);

    await container.read(exportServiceProvider).export(ExportFormat.csv);

    final file = sharer.shared.single;
    expect(file.fileName, 'rateby-expenses-2026-10-22.csv');
    expect(file.mimeType, 'text/csv');
    final text = utf8.decode(file.bytes);
    expect(text, contains('2026-10-22,17:00,23.00'));
  });

  test('Plus users get a PDF report', () async {
    final sharer = FakeFileSharer();
    final container = makeContainer(sharer);

    await container.read(exportServiceProvider).export(ExportFormat.pdf);

    final file = sharer.shared.single;
    expect(file.fileName, 'rateby-report-2026-10-22.pdf');
    expect(file.mimeType, 'application/pdf');
    expect(looksLikePdf(file.bytes), isTrue);
  });

  test('before onboarding there is nothing to export', () async {
    final sharer = FakeFileSharer();
    final container = makeContainer(sharer, demo: false);

    await expectLater(
      container.read(exportServiceProvider).export(ExportFormat.pdf),
      throwsA(isA<NothingToExportException>()),
    );
    expect(sharer.shared, isEmpty);
  });
}
