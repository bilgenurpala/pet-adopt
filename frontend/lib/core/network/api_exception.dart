class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException() : super('Please check your internet connection.');
}

class ServerException extends ApiException {
  const ServerException() : super('Something went wrong on the server.');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('You are not authorized.');
}

class NotFoundException extends ApiException {
  const NotFoundException() : super('Requested resource not found.');
}
