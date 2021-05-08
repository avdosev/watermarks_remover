import 'package:flutter/material.dart';
import 'package:web/stores/auth_store.dart';
import './pages/main_page.dart';
import './pages/auth_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(Root());
}

class Root extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthStore>(create: (_) => AuthStore()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authStore = context.watch<AuthStore>();
    if (authStore.token == null) {
      return AuthPage();
    } else {
      print('Token: ${authStore.token}');
      return MainPage();
    }
  }
}
