class AsyncUtils {
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
