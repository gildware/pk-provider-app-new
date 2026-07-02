import 'package:get/get.dart';

/// Extracts a user-facing message from API error responses.
class ApiErrorHelper {
  static String? extractMessage(Response response) {
    final body = response.body;
    if (body is Map) {
      final fromErrors = _messageFromErrors(body['errors']);
      if (fromErrors != null) {
        return fromErrors;
      }

      final fromFields = _messageFromErrors(body['fields']);
      if (fromFields != null) {
        return fromFields;
      }

      final error = body['error'];
      if (error is Map && error['message'] != null) {
        final message = error['message'].toString();
        if (message.isNotEmpty && !_isGenericServerMessage(message)) {
          return message;
        }
      } else if (error is String && error.isNotEmpty && !_isGenericServerMessage(error)) {
        return error;
      }

      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty && !_isGenericServerMessage(message)) {
        return message;
      }
    }

    final statusText = response.statusText;
    if (statusText != null &&
        statusText.isNotEmpty &&
        !_isGenericServerMessage(statusText)) {
      return statusText;
    }

    return null;
  }

  static String? _messageFromErrors(dynamic errors) {
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map && first['message'] != null) {
        return first['message'].toString();
      }
      if (first is String && first.isNotEmpty) {
        return first;
      }
    }

    if (errors is Map && errors.isNotEmpty) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  static bool _isGenericServerMessage(String message) {
    final lower = message.trim().toLowerCase();
    return lower == 'internal server error' || lower == 'server error';
  }
}
