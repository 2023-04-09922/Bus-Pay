class Failure implements Exception {
  Failure(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}
