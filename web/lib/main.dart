import 'package:flutter/material.dart';
import 'package:web/stores/auth_store.dart';
import 'package:web/stores/files_loader_store.dart';
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
        ChangeNotifierProvider<AuthStore>(create: (_) => AuthStore()),
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
    return Consumer<AuthStore>(builder: (_, authStore, __) {
      print('Rebuild home');
      final authToken = authStore.token;
      if (authToken == null) {
        return AuthPage(key: ValueKey('auth_page'));
      } else {
        print('Token: ${authStore.token}');
        return ChangeNotifierProvider<FileUploader>(
            create: (_) => FileUploader(authToken)..startUpdating(),
            builder: (_, __) => MainPage());
      }
    });
  }
}
