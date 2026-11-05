import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/constants/app_info.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';
import 'package:rateby/features/legal/domain/legal_content.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';

import '../../support/legal_source.dart';

String allText(LegalDocument doc) => [
      doc.title,
      doc.intro,
      for (final s in doc.sections) ...[
        s.heading,
        for (final b in s.blocks)
          switch (b) {
            LegalParagraph(:final text) => text,
            LegalBullets(:final items) => items.join('\n'),
          },
      ],
    ].join('\n');

String withAds(bool on) {
  final json = jsonDecode(readLegalJson()) as Map<String, Object?>;
  json['features'] = {'ads': on};
  return jsonEncode(json);
}

void main() {
  final source = readLegalJson();

  test('all three documents load in Arabic and are not empty', () {
    final content = LegalContent.parse(source);
    for (final kind in LegalKind.values) {
      final doc = content.document(kind);
      expect(doc.title, isNotEmpty);
      expect(doc.intro, isNotEmpty);
      expect(doc.sections.length, greaterThanOrEqualTo(5));
      expect(allText(doc), isNot(contains('{{')));
    }
    expect(content.document(LegalKind.privacy).title, 'سياسة الخصوصية');
    expect(content.document(LegalKind.terms).title, 'شروط الاستخدام');
  });

  test('Arabic and English have the same structure', () {
    final ar = LegalContent.parse(source);
    final en = LegalContent.parse(source, lang: 'en');
    for (final kind in LegalKind.values) {
      final a = ar.document(kind).sections;
      final e = en.document(kind).sections;
      expect(a.length, e.length, reason: '$kind sections');
      for (var i = 0; i < a.length; i++) {
        expect(a[i].blocks.length, e[i].blocks.length, reason: '$kind §$i');
      }
    }
  });

  test('prices, trial and goal limit quoted in the terms match the app', () {
    final terms = allText(LegalContent.parse(source).document(LegalKind.terms));
    expect(terms, contains('9 ر.س شهرياً'));
    expect(terms, contains('67 ر.س سنوياً'));
    expect(terms, contains('${PlusPlan.trialDays} أيام'));
    expect(terms, contains('${PlusLimits.freeGoalCount} أهداف'));
    expect(PlusPlan.monthlyPrice.halalas, 900);
    expect(PlusPlan.yearlyPrice.halalas, 6700);
  });

  test('iPhone prices quoted in the terms match the App Store prices', () {
    final terms = allText(LegalContent.parse(source).document(LegalKind.terms));
    expect(terms, contains('9.99 ر.س شهرياً'));
    expect(terms, contains('69.99 ر.س سنوياً'));
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(PlusPlan.monthlyPrice.halalas, 999);
    expect(PlusPlan.yearlyPrice.halalas, 6999);
    expect(PlusPlan.yearlySavingsPercent, 42);
  });

  test('the policy says what the build does about ads', () {
    final content = LegalContent.parse(source);
    expect(content.showsAds, AppInfo.hasAds);
  });

  test('without ads the policy does not mention an ad network', () {
    final content = LegalContent.parse(withAds(false));
    for (final kind in LegalKind.values) {
      expect(allText(content.document(kind)), isNot(contains('AdMob')));
    }
  });

  test('with ads on, the privacy policy discloses AdMob and the advertising ID',
      () {
    final privacy =
        allText(LegalContent.parse(withAds(true)).document(LegalKind.privacy));
    expect(privacy, contains('AdMob'));
    expect(privacy, contains('معرّف الإعلانات'));
    expect(privacy, isNot(contains('{{')));
  });

  test('the support email is exposed for the support action', () {
    expect(LegalContent.parse(source).supportEmail, contains('@'));
  });

  test('a broken file is a FormatException, not a crash later', () {
    expect(() => LegalContent.parse('not json'), throwsFormatException);
    expect(() => LegalContent.parse('{"meta": 1}'), throwsFormatException);
  });

  test('an unknown placeholder is an error', () {
    final json = jsonDecode(source) as Map<String, Object?>;
    final docs = json['documents']! as Map<String, Object?>;
    final privacy = docs['privacy']! as Map<String, Object?>;
    (privacy['ar']! as Map<String, Object?>)['intro'] = 'مرحباً {{nope}}';
    expect(() => LegalContent.parse(jsonEncode(json)), throwsFormatException);
  });

  test('the in-app limit message and the terms agree on the free limit', () {
    expect(
      GoalsStrings.limitReached(PlusLimits.freeGoalCount),
      contains('${PlusLimits.freeGoalCount}'),
    );
  });
}
