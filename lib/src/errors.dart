/// Wrapper around an error thrown by the REST API itself
class ApiException implements Exception {
  final String message;

  ApiException([this.message]);

  factory ApiException.fromJson([Map message]) {
    if (message == null) {
      return ApiException();
    } else if (message.containsKey('messageTranslations')) {
      return ApiException(message['messageTranslations']['en']);
    } else if (message.containsKey('message')) {
      return ApiException(message['message']);
    } else if (message.containsKey('httpCode') &&
        message.containsKey('httpReason')) {
      return ApiException('${message['httpCode']}: ${message['httpReason']}');
    } else if (message.containsKey('errors')) {
      return ApiException(message['errors'][0]['text']);
    } else {
      return ApiException(message['error']['info']);
    }
  }
}

/// Error thrown if something is wrong with API response
class InvalidResponseException implements Exception {
  final String message = 'Invalid API response recieved';
}
