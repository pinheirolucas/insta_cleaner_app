import "dart:io" show HttpStatus;

import "package:flutter/material.dart";
import "package:insta_cleaner/di.dart" as di;
import "package:meta/meta.dart" show protected;

import "auth_service.dart" show AuthService;
import "retry_view.dart" show RetryView;
import "utils/http.dart" show BadHTTPStatusException;

abstract class AuthHandler {
  @protected
  AuthService get authService => di.Container.retrieve<AuthService>();

  Widget handleBadResponse(AsyncSnapshot snapshot, Function onRetry) {
    if (snapshot.error.runtimeType == BadHTTPStatusException) {
      final e = snapshot.error as BadHTTPStatusException;

      if (e.status == HttpStatus.unauthorized) {
        authService.logout();
      }
    }

    return RetryView(
      errorTitle: "Erro",
      errorDetail: "Algum erro desconhecido aconteceu",
      iconData: Icons.sentiment_very_dissatisfied,
      retryText: "TENTAR NOVAMENTE",
      onRetry: onRetry,
    );
  }
}
