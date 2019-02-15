import "package:flutter/material.dart" show runApp;
import "package:insta_cleaner/di.dart" as di;

import "app.dart" show configureDi, InstaCleaner;
import "config.dart" show AppConfig;

Future<void> main() async {
  di.Container.registerSingleton<AppConfig>(di.Provider.fromInstance(AppConfig(apiAddress: "http://10.0.2.2:8080")));
  await configureDi();

  runApp(InstaCleaner());
}
