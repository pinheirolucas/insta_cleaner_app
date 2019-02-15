import "dart:convert" show jsonDecode;

import "package:http/http.dart" as http;
import "package:insta_cleaner/di.dart" show Container;

import "auth_service.dart" show AuthService;
import "config.dart" show AppConfig;
import "utils/http.dart" show handleServiceError;

abstract class UsersService {
  Future<List<User>> getFollowing();
  Future<List<User>> search(String username);
  Future<User> follow(String username);
  Future<User> unfollow(String username);
}

class UsersServiceImpl implements UsersService {
  factory UsersServiceImpl() => UsersServiceImpl.inject(
        Container.retrieve<AuthService>(),
        Container.retrieve<http.Client>(),
        Container.retrieve<AppConfig>(),
      );
  UsersServiceImpl.inject(this._authService, this._client, this._config);

  final AuthService _authService;
  final http.Client _client;
  final AppConfig _config;

  @override
  Future<List<User>> getFollowing() async {
    final url = "${_config.apiAddress}/users/following";

    final headers = await _authService.getHeaders();

    final response = await _client.get(url, headers: headers);

    handleServiceError(response);

    return jsonDecode(response.body)?.map<User>((json) => User.fromJson(json))?.toList() ?? <User>[];
  }

  @override
  Future<List<User>> search(String username) async {
    final url = "${_config.apiAddress}/users/search?username=$username";

    final headers = await _authService.getHeaders();

    final response = await _client.get(url, headers: headers);

    handleServiceError(response);

    return jsonDecode(response.body)?.map<User>((json) => User.fromJson(json))?.toList() ?? <User>[];
  }

  @override
  Future<User> follow(String username) async {
    final url = "${_config.apiAddress}/users/follow?username=$username";

    final headers = await _authService.getHeaders();

    final response = await _client.post(url, headers: headers);

    handleServiceError(response);

    return User.fromJson(jsonDecode(response.body));
  }

  @override
  Future<User> unfollow(String username) async {
    final url = "${_config.apiAddress}/users/unfollow?username=$username";

    final headers = await _authService.getHeaders();

    final response = await _client.post(url, headers: headers);

    handleServiceError(response);

    return User.fromJson(jsonDecode(response.body));
  }
}

class User {
  User(
      {this.id,
      this.name,
      this.username,
      this.profileUrl,
      this.profilePic,
      isFollowing = false,
      this.isVerified = false})
      : this._isFollowing = isFollowing;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        username: json["username"] ?? "",
        profileUrl: json["profileUrl"] ?? "",
        profilePic: json["profilePic"] ?? "",
        isFollowing: json["isFollowing"] ?? false,
        isVerified: json["isVerified"] ?? false,
      );

  final int id;
  final String name;
  final String username;
  final String profileUrl;
  final String profilePic;
  final bool isVerified;

  bool _isFollowing;
  bool get isFollowing => _isFollowing;

  void follow() {
    _isFollowing = true;
  }

  void unfollow() {
    _isFollowing = false;
  }
}
