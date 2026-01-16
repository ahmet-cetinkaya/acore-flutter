abstract class IContainer {
  IContainer get instance;

  T resolve<T>();

  void registerSingleton<T>(T Function(IContainer) factory);

  /// Check if a type is registered in the container
  bool isRegistered<T>();

  /// Clear all registrations in the container
  void clear();
}
