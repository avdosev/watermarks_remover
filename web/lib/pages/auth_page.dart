import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/loading_status.dart';
import 'package:web/stores/auth_store.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          height: 600,
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Consumer<AuthStore>(
              builder: (context, store, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Введите email',
                    ),
                    validator: emailValidator,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Введите пароль',
                    ),
                    validator: passwordValidator,
                  ),
                  if (store.requestStatus == null ||
                      store.requestStatus == LoadingStatus.corrupted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              store.auth(emailController.text,
                                  passwordController.text);
                            }
                          },
                          child: const Text('Войти'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              minimumSize: Size(200, 50)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              store.registration(emailController.text,
                                  passwordController.text);
                            }
                          },
                          child: const Text('Регистрация'),
                        ),
                      ],
                    )
                  else
                    const CircularProgressIndicator()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Нужно ввести email';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Нужно ввести пароль';
  }
  return null;
}
