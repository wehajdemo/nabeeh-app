/// Overall state of today's spending — drives the semantic colors
/// (safe / warning / danger) described in DESIGN.md.
enum BudgetHealth {
  /// Plenty of today's allowance left.
  onTrack,

  /// Most of today's allowance is gone.
  nearLimit,

  /// Today's limit has been reached or passed.
  exceeded,
}
