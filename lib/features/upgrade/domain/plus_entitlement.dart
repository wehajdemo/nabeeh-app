import 'package:flutter/foundation.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';

/// Whether the user currently has "نبيه بلس", as confirmed by the server.
@immutable
class PlusEntitlement {
  const PlusEntitlement({required this.active, this.plan, this.expiresAt});

  const PlusEntitlement.none()
      : active = false,
        plan = null,
        expiresAt = null;

  final bool active;
  final PlusPlanType? plan;

  /// End of the paid period (`null` = no known end).
  final DateTime? expiresAt;

  /// Active and not past its end date. The end date lets the app keep
  /// working offline without trusting a stale "active" flag forever.
  bool isActiveAt(DateTime now) =>
      active && (expiresAt == null || expiresAt!.isAfter(now));

  Map<String, Object?> toJson() => {
        'active': active,
        'plan': plan?.name,
        'expiresAt': expiresAt?.millisecondsSinceEpoch,
      };

  /// `null` for anything malformed.
  static PlusEntitlement? fromJson(Object? json) {
    if (json is! Map) return null;
    final active = json['active'];
    if (active is! bool) return null;
    final planName = json['plan'];
    final expires = json['expiresAt'];
    return PlusEntitlement(
      active: active,
      plan: PlusPlanType.values.where((p) => p.name == planName).firstOrNull,
      expiresAt: expires is int
          ? DateTime.fromMillisecondsSinceEpoch(expires)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlusEntitlement &&
      other.active == active &&
      other.plan == plan &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(active, plan, expiresAt);
}
