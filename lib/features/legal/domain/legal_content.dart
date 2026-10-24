import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rateby/core/constants/app_strings.dart';

enum LegalKind { privacy, terms, support }

@immutable
sealed class LegalBlock {
  const LegalBlock();
}

class LegalParagraph extends LegalBlock {
  const LegalParagraph(this.text);
  final String text;
}

class LegalBullets extends LegalBlock {
  const LegalBullets(this.items);
  final List<String> items;
}

@immutable
class LegalSection {
  const LegalSection({required this.heading, required this.blocks});
  final String heading;
  final List<LegalBlock> blocks;
}

@immutable
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.intro,
    required this.effectiveDate,
    required this.sections,
  });

  final String title;
  final String intro;
  final String effectiveDate;
  final List<LegalSection> sections;
}

/// Privacy policy, terms and support text, read from
/// `assets/legal/legal.json` — the same file the hosted web pages are
/// generated from (`admin/legal/render.mjs` applies the same rules).
@immutable
class LegalContent {
  const LegalContent._({
    required this.supportEmail,
    required this.showsAds,
    required Map<LegalKind, LegalDocument> documents,
  }) : _documents = documents;

  /// [lang] is `ar` in the app; `en` exists for the hosted pages and tests.
  /// Throws [FormatException] if the file is malformed.
  factory LegalContent.parse(String source, {String lang = 'ar'}) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('legal.json is not valid JSON');
    }
    final root = _map(decoded, 'root');
    final meta = _map(root['meta'], 'meta');
    final features = _map(root['features'] ?? const <String, Object?>{}, 'features');
    final docs = _map(root['documents'], 'documents');

    final values = _placeholders(meta, lang);
    bool visible(Object? onlyIf) {
      if (onlyIf == null) return true;
      final flag = onlyIf as String;
      return flag.startsWith('!')
          ? features[flag.substring(1)] != true
          : features[flag] == true;
    }

    String fill(Object? text) => (text as String).replaceAllMapped(
          RegExp(r'\{\{(\w+)\}\}'),
          (m) =>
              values[m[1]] ??
              (throw FormatException('Unknown placeholder {{${m[1]}}}')),
        );

    LegalDocument build(LegalKind kind) {
      final source = _map(_map(docs[kind.name], kind.name)[lang], '${kind.name}.$lang');
      final sections = <LegalSection>[];
      for (final raw in source['sections']! as List<Object?>) {
        final section = _map(raw, 'section');
        if (!visible(section['onlyIf'])) continue;
        final blocks = <LegalBlock>[];
        for (final block in section['blocks']! as List<Object?>) {
          if (block is String) {
            blocks.add(LegalParagraph(fill(block)));
          } else {
            final map = _map(block, 'block');
            final bullets = map['bullets'];
            if (bullets is List<Object?>) {
              final items = [
                for (final item in bullets)
                  if (item is String)
                    fill(item)
                  else if (visible(_map(item, 'bullet')['onlyIf']))
                    fill((item! as Map<String, Object?>)['text']),
              ];
              if (items.isNotEmpty) blocks.add(LegalBullets(items));
            } else if (visible(map['onlyIf'])) {
              blocks.add(LegalParagraph(fill(map['text'])));
            }
          }
        }
        if (blocks.isNotEmpty) {
          sections.add(LegalSection(heading: fill(section['heading']), blocks: blocks));
        }
      }
      return LegalDocument(
        title: fill(source['title']),
        intro: fill(source['intro']),
        effectiveDate: values['effectiveDate']!,
        sections: sections,
      );
    }

    return LegalContent._(
      supportEmail: meta['supportEmail']! as String,
      showsAds: features['ads'] == true,
      documents: {for (final kind in LegalKind.values) kind: build(kind)},
    );
  }

  final String supportEmail;

  /// `features.ads` of the file (checked against `AppInfo.hasAds` in tests).
  final bool showsAds;
  final Map<LegalKind, LegalDocument> _documents;

  LegalDocument document(LegalKind kind) => _documents[kind]!;

  static Map<String, Object?> _map(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    throw FormatException('legal.json: "$what" must be an object');
  }

  static Map<String, String> _placeholders(Map<String, Object?> meta, String lang) {
    String localized(String key) => _map(meta[key], key)[lang]! as String;
    String money(Object? amount) =>
        lang == 'ar' ? '$amount ${AppStrings.currencySymbol}' : 'SAR $amount';
    return {
      'appName': localized('appName'),
      'developerName': localized('developerName'),
      'supportEmail': meta['supportEmail']! as String,
      'effectiveDate': localized('effectiveDate'),
      'monthlyPrice': money(meta['monthlyPriceSar']),
      'yearlyPrice': money(meta['yearlyPriceSar']),
      'trialDays': '${meta['trialDays']}',
      'freeGoals': '${meta['freeGoalCount']}',
    };
  }
}
