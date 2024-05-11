import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/login_page.dart';
import '../pages/tabs_page.dart';
import '../services/appwrite/auth_api.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authAPI = context.watch<AuthAPI>();

    switch (authAPI.status) {
      case AuthStatus.uninitialized:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        final user = authAPI.currentUser;
        if (user != null && !user.emailVerification) {
          return const LoginPage();
        } else {
          return Navigator(
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (context) => const TabsPage(),
                settings: routeSettings,
              );
            },
          );
        }
      default:
        return const LoginPage();
    }
  }
}

