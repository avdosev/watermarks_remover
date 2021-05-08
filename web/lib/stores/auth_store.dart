import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../loading_status.dart';
import 'dart:convert';

class AuthStore extends ChangeNotifier {
  String? token;
  LoadingStatus? requestStatus;

  AuthStore();

  Future<void> auth(String email, String password) async {
    try {
      requestStatus = LoadingStatus.inProgress;
      final response = await http.get(
          Uri.http('/', 'api/user', {'email': email, 'password': password}));
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        token = res['user_id'];
        requestStatus = LoadingStatus.finaly;
      } else {
        requestStatus = LoadingStatus.corrupted;
      }
    } catch (err) {
      requestStatus = LoadingStatus.corrupted;
    }
    notifyListeners();
  }

  Future<void> registration(String email, String password) async {
    try {
      requestStatus = LoadingStatus.inProgress;
      final response = await http.post(
        Uri.http('/', 'api/user'),
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
      requestStatus = LoadingStatus.corrupted;
    }
    notifyListeners();
  }
}
