import "provider.dart" show Provider;

class Container {
  static final _container = <Type, _ContainerItem>{};

  static void registerSingleton<T>(Provider provider) {
    _container.putIfAbsent(T, () => _ContainerItem.singleton(provider));
  }

  static void registerTransient<T>(Provider provider) {
    _container.putIfAbsent(T, () => _ContainerItem.transient(provider));
  }

  static T retrieve<T>() {
    if (!_container.containsKey(T)) {
      throw ProviderNotFoundException(T);
    }

    return _container[T]?.getElement() as T;
  }
}

class ProviderNotFoundException implements Exception {
  ProviderNotFoundException(this._type);

  final Type _type;

  @override
  String toString() => "Provider not found for type: $_type";
}

class _ContainerItem {
  _ContainerItem.singleton(this._provider) : _storeInstance = true;
  _ContainerItem.transient(this._provider) : _storeInstance = false;

  final bool _storeInstance;
  final Provider _provider;
  Object _instance;

  Object getElement() => _storeInstance && _instance != null ? _instance : _instance = _provider.getInstance();
}
