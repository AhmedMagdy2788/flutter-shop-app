import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  static final String signUpURL =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyD9-CRXXtbQLtNdQgZmepd-u-QYQX1il1M';
  static final String signInURL =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyD9-CRXXtbQLtNdQgZmepd-u-QYQX1il1M';
  String _token;
  String _email;
  String _password;
  String _refreshToken;
  DateTime _expireDate;
  String _localID;
  bool _isRegistered;

  bool get isAuthenticated{
    if(token == null) return false;
    return true;
  }

  String get token{
    if(_token != null && _expireDate != null && _expireDate.isAfter(DateTime.now()))
    return _token;
    return null;
  }

  Future<void> _authenticate(String email, String password, String url) async {
    try{
      var response = await http.post(url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
    Map<String, dynamic> responseDecoded = json.decode(response.body);
    print(responseDecoded);
    if (responseDecoded['error'] != null) {
      throw HttpException(responseDecoded['error']['message']);
    } else {
      DateTime responseDate = DateTime.now();
      _token = responseDecoded['idToken'];
      // print(idToken);
      email = responseDecoded['email'];
      this._password = password;
      _refreshToken = responseDecoded['refreshToken'];
      // print(refreshToken);
      _expireDate = responseDate
          .add(Duration(seconds: int.parse(responseDecoded['expiresIn'])));
      // print(expireDate.toIso8601String());
      _localID = responseDecoded['localId'];
      // print(localID);
      _isRegistered = (responseDecoded['registered'] == 'false') ? false : true;
      // print(responseDecoded['registered'] );
      notifyListeners();
    }
    }catch(error){
      print(error.toString());
    }
  }

  Future<void> signUpUser(String email, String password) async {
    return _authenticate(email, password, signUpURL);
  }

  Future<void> signInUser(String email, String password) async {
    return _authenticate(email, password, signInURL);
  }
}
