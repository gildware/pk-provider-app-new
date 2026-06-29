class BookingCount {
  int? all;
  int? pending;
  int? accepted;
  int? pendingCancellation;
  int? ongoing;
  int? onHold;
  int? completed;
  int? canceled;
  int? reopened;
  int? resolved;
  int? disputedCancelled;
  int? disputedCompleted;
  int? holdAfterVisit;
  int? completedNoOrLittle;
  int? cancelledAfterVisit;
  int? lossMakingPending;
  int? lossRecovered;
  int? lossSettled;

  BookingCount({
    this.all,
    this.pending,
    this.accepted,
    this.pendingCancellation,
    this.ongoing,
    this.onHold,
    this.completed,
    this.canceled,
    this.reopened,
    this.resolved,
    this.disputedCancelled,
    this.disputedCompleted,
    this.holdAfterVisit,
    this.completedNoOrLittle,
    this.cancelledAfterVisit,
    this.lossMakingPending,
    this.lossRecovered,
    this.lossSettled,
  });

  BookingCount.fromJson(Map<String, dynamic> json) {
    all = _readCount(json['all']);
    pending = _readCount(json['pending']);
    accepted = _readCount(json['accepted']);
    pendingCancellation = _readCount(json['pending_cancellation']);
    ongoing = _readCount(json['ongoing']);
    onHold = _readCount(json['on_hold']);
    completed = _readCount(json['completed']);
    canceled = _readCount(json['canceled']);
    reopened = _readCount(json['reopened']);
    resolved = _readCount(json['resolved']);
    disputedCancelled = _readCount(json['disputed_cancelled']);
    disputedCompleted = _readCount(json['disputed_completed']);
    holdAfterVisit = _readCount(json['hold_after_visit']);
    completedNoOrLittle = _readCount(json['completed_no_or_little']);
    cancelledAfterVisit = _readCount(json['cancelled_after_visit']);
    lossMakingPending = _readCount(json['loss_making_pending']);
    lossRecovered = _readCount(json['loss_recovered']);
    lossSettled = _readCount(json['loss_settled']);
  }

  static int _readCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    final raw = value.toString().trim();
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? double.tryParse(raw)?.round() ?? 0;
  }

  int countForTab(String tab) {
    switch (tab) {
      case 'all':
        return all ?? 0;
      case 'pending':
        return pending ?? 0;
      case 'accepted':
        return accepted ?? 0;
      case 'pending_cancellation':
        return pendingCancellation ?? 0;
      case 'ongoing':
        return ongoing ?? 0;
      case 'on_hold':
        return onHold ?? 0;
      case 'completed':
        return completed ?? 0;
      case 'canceled':
        return canceled ?? 0;
      case 'reopened':
        return reopened ?? 0;
      case 'resolved':
        return resolved ?? 0;
      case 'disputed_cancelled':
        return disputedCancelled ?? 0;
      case 'disputed_completed':
        return disputedCompleted ?? 0;
      case 'hold_after_visit':
        return holdAfterVisit ?? 0;
      case 'completed_no_or_little':
        return completedNoOrLittle ?? 0;
      case 'cancelled_after_visit':
        return cancelledAfterVisit ?? 0;
      case 'loss_making_pending':
        return lossMakingPending ?? 0;
      case 'loss_recovered':
        return lossRecovered ?? 0;
      case 'loss_settled':
        return lossSettled ?? 0;
      default:
        return 0;
    }
  }
}
