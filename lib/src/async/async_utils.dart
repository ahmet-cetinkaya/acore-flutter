/// Simple utility for executing async operations with basic error handling.
class AsyncUtils {
  /// Executes an async operation and handles errors with a callback.
  static Future<T?> executeAsync<T>({
    required Future<T> Function() operation,
    void Function(T result)? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
    VoidCallback? onFinally,
  }) async {
    try {
      final result = await operation();
      onSuccess?.call(result);
      return result;
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      return null;
    } finally {
      onFinally?.call();
    }
  }

  /// Executes an async void operation with basic error handling.
  static Future<void> executeAsyncVoid({
    required Future<void> Function() operation,
    VoidCallback? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
    VoidCallback? onFinally,
  }) async {
    try {
      await operation();
      onSuccess?.call();
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
    } finally {
      onFinally?.call();
    }
  }
}

typedef VoidCallback = void Function();
