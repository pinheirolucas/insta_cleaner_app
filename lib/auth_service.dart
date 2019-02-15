import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show HttpStatus;

import "package:flutter_secure_storage/flutter_secure_storage.dart" show FlutterSecureStorage;
import "package:http/http.dart" as http;
import "package:insta_cleaner/di.dart" show Container;

import "config.dart" show AppConfig;

abstract class AuthService {
  Future<Map<String, String>> getHeaders();

  Future<bool> isAuthenticated();
  Future<String> getSessionKey();
  Future<LoginResponse> login(String username, String password);
  Future<void> logout();
}

class AuthServiceImpl implements AuthService {
  factory AuthServiceImpl() => AuthServiceImpl.inject(
        Container.retrieve<http.Client>(),
        Container.retrieve<AppConfig>(),
        Container.retrieve<FlutterSecureStorage>(),
      );
  AuthServiceImpl.inject(this._client, this._config, this._secureStorage);

  static const _sessionKey = "sessionKey";

  final FlutterSecureStorage _secureStorage;
  final http.Client _client;
  final AppConfig _config;

  @override
  Future<Map<String, String>> getHeaders() async => {
        "Authorization": "Basic ${await getSessionKey()}",
      };

  @override
  Future<String> getSessionKey() => _secureStorage.read(key: _sessionKey);

  @override
  Future<bool> isAuthenticated() async {
    final sessionKey = await _secureStorage.read(key: _sessionKey);

    return sessionKey?.isNotEmpty ?? false;
  }

  @override
  Future<LoginResponse> login(String username, String password) async {
    final url = "${_config.apiAddress}/auth/login";

    final response = await _client.post(url, body: jsonEncode({"username": username, "password": password}));

    switch (response.statusCode) {
      case HttpStatus.ok:
        // continue
        break;
      case HttpStatus.notFound:
        return LoginResponse(false, message: "Usuário e senha inválidos");
      default:
        return LoginResponse(false, message: "Erro desconhecido");
    }

    final session = jsonDecode(response.body);

    await _setSessionKey(session[_sessionKey]);

    return LoginResponse(true);
  }

  Future<void> _setSessionKey(String sessionKey) async =>
      await _secureStorage.write(key: _sessionKey, value: sessionKey);

  @override
  Future<void> logout() async => await _secureStorage.delete(key: _sessionKey);
}

class LoginResponse {
  const LoginResponse(this.success, {this.message});

  final bool success;
  final String message;
}
