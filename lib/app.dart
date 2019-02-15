import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart" show FlutterSecureStorage;
import "package:http/http.dart" as http;
import "package:insta_cleaner/di.dart" as di;
import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

import "home_page.dart" show HomePage;
import "login/login_page.dart" show LoginPage;
import "auth_service.dart" show AuthService, AuthServiceImpl;
import "search_history_service.dart" show SearchHistoryService, SearchHistoryServiceImpl;
import "users_service.dart" show UsersService, UsersServiceImpl;

Future<void> configureDi() async {
  final prefs = await SharedPreferences.getInstance();

  di.Container.registerSingleton<AuthService>(di.Provider.fromFactory(() => AuthServiceImpl()));
  di.Container.registerSingleton<FlutterSecureStorage>(di.Provider.fromFactory(() => FlutterSecureStorage()));
  di.Container.registerSingleton<SharedPreferences>(di.Provider.fromInstance(prefs));

  di.Container.registerTransient<http.Client>(di.Provider.fromFactory(() => http.Client()));
  di.Container.registerTransient<UsersService>(di.Provider.fromFactory(() => UsersServiceImpl()));
  di.Container.registerTransient<SearchHistoryService>(di.Provider.fromFactory(() => SearchHistoryServiceImpl()));
}

class InstaCleaner extends StatefulWidget {
  factory InstaCleaner() => InstaCleaner.inject(
        di.Container.retrieve<AuthService>(),
        di.Container.retrieve<FlutterSecureStorage>(),
      );
  InstaCleaner.inject(this.authService, this.secureStorage);

  final FlutterSecureStorage secureStorage;
  final AuthService authService;

  @override
  State<StatefulWidget> createState() => _InstaCleanerState();
}

class _InstaCleanerState extends State<InstaCleaner> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Insta Cleaner",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: widget.authService.isAuthenticated(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done && snapshot.data is bool && snapshot.data as bool
                ? HomePage()
                : LoginPage(
                    onLogin: _onLogin,
                  ),
      ),
    );
  }

  Future<void> _onLogin(String username, String password, Function reportError) async {
    final response = await widget.authService.login(username, password);

    if (!response.success) {
      reportError(response.message);
    }

    setState(() {});
  }
}
