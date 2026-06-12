import 'exceptions.dart';

/// Abstract result type for clean architecture.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    _ => null,
  };

  String? get errorOrNull => switch (this) {
    Failure<T>(message: final m) => m,
    _ => null,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, AppException? exception) failure,
  }) => switch (this) {
    Success<T>(data: final d) => success(d),
    Failure<T>(message: final m, :final exception) => failure(m, exception),
  };
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final AppException? exception;
  const Failure(this.message, {this.exception});
}
