import 'package:newlane/core/errors/failures.dart';

/// Success or failure from a use case / repository.
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

extension ResultX<T> on Result<T> {
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) {
    return switch (this) {
      Ok<T>(:final T value) => ok(value),
      Err<T>(:final Failure failure) => err(failure),
    };
  }
}
