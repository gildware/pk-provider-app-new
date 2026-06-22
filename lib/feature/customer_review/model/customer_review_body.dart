class CustomerReviewBody {
  final String bookingId;
  final String rating;
  final String comment;

  CustomerReviewBody({
    required this.bookingId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'review_rating': rating,
      'review_comment': comment,
    };
  }
}
