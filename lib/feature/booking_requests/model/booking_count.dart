class BookingCount {
  int? pending;
  int? accepted;
  int? ongoing;
  int? onHold;
  int? completed;
  int? canceled;
  int? refunded;

  BookingCount(
      {this.pending,
        this.accepted,
        this.ongoing,
        this.onHold,
        this.completed,
        this.canceled,
        this.refunded});

  BookingCount.fromJson(Map<String, dynamic> json) {
    pending = int.tryParse(json['pending'].toString());
    accepted = int.tryParse(json['accepted'].toString());
    ongoing = int.tryParse(json['ongoing'].toString());
    onHold = int.tryParse(json['on_hold'].toString());
    completed = int.tryParse(json['completed'].toString());
    canceled = int.tryParse(json['canceled'].toString());
    refunded = int.tryParse(json['refunded'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['ongoing'] = ongoing;
    data['on_hold'] = onHold;
    data['completed'] = completed;
    data['canceled'] = canceled;
    data['refunded'] = refunded;
    return data;
  }
}