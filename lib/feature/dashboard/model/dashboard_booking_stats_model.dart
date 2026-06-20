class BookingStatusStat {
  final String status;
  final int count;

  const BookingStatusStat({required this.status, required this.count});

  factory BookingStatusStat.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['booking_status'] ?? '').toString().toLowerCase();
    final normalized = rawStatus == 'cancelled' ? 'canceled' : rawStatus;

    return BookingStatusStat(
      status: normalized,
      count: int.tryParse('${json['total']}') ?? 0,
    );
  }

  static const List<String> displayOrder = [
    'pending',
    'accepted',
    'ongoing',
    'on_hold',
    'completed',
    'canceled',
    'refunded',
  ];

  static List<BookingStatusStat> sorted(List<BookingStatusStat> stats) {
    final filtered = stats.where((item) => item.count > 0).toList();
    filtered.sort((a, b) {
      final indexA = displayOrder.indexOf(a.status);
      final indexB = displayOrder.indexOf(b.status);
      final safeA = indexA == -1 ? displayOrder.length : indexA;
      final safeB = indexB == -1 ? displayOrder.length : indexB;
      if (safeA != safeB) return safeA.compareTo(safeB);
      return a.status.compareTo(b.status);
    });
    return filtered;
  }
}
