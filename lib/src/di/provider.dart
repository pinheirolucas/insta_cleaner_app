typedef Object FactoryFunc();

abstract class Provider {
  factory Provider.fromInstance(Object instance) => _InstanceProvider(instance);
  factory Provider.fromFactory(FactoryFunc fac) => _FactoryProvider(fac);

  Object getInstance();
}

class _InstanceProvider implements Provider {
  _InstanceProvider(this._instance);

  final Object _instance;

  @override
  Object getInstance() => _instance;
}

class _FactoryProvider implements Provider {
  _FactoryProvider(this._factory);

  final FactoryFunc _factory;

  @override
  Object getInstance() {
    if (_factory == null) {
      return null;
    }

    return _factory();
  }
}
