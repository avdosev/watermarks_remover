import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../loading_status.dart';
import 'dart:convert';

class AuthStore extends ChangeNotifier {
  String? token;
  LoadingStatus? requestStatus;

  AuthStore();

  Future<void> auth(String email, String password) async {
    print('try auth');
    try {
      requestStatus = LoadingStatus.inProgress;
      notifyListeners();
      final response = await http.get(Uri.base.replace(
          path: 'api/user',
          queryParameters: {'email': email, 'password': password}));
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        token = res['user_id'];
        requestStatus = LoadingStatus.finaly;
      } else {
        requestStatus = LoadingStatus.corrupted;
      }
    } catch (err) {
      print(err);
      requestStatus = LoadingStatus.corrupted;
    }
    print('end auth with token: $token');
    notifyListeners();
  }

  Future<void> registration(String email, String password) async {
    print('try registration');
    try {
      requestStatus = LoadingStatus.inProgress;
      notifyListeners();
      final response = await http.post(
        Uri.base.replace(path: 'api/user'),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        token = res['user_id'];
        requestStatus = LoadingStatus.finaly;
      } else {
        requestStatus = LoadingStatus.corrupted;
      }
    } catch (err) {
      print(err);
      requestStatus = LoadingStatus.corrupted;
    }
    print('end registration with token: $token');
    notifyListeners();
  }
}
