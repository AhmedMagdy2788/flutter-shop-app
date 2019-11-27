import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  static String nameArg = 'product';
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String ownerID;
  bool favourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.ownerID,
    this.favourite = false,
  });

  String toJSON() {
    return convert.json.encode({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'ownerID': ownerID,
    });
  }

  Future<void> toggleFavorite(String userID, String token) async {
    this.favourite = !this.favourite;
    notifyListeners();
    var response = await http.put(
        'https://flutter-shop-app-31c34.firebaseio.com/$userID/${this.id}.json?auth=$token',
        body: convert.json.encode(
          this.favourite,
        ));
    if (response.statusCode >= 400) {
      this.favourite = !this.favourite;
      print(response.body);
      notifyListeners();
    } else {
      // notifyListeners();
      print('toggle Favorites of $title');
    }
  }
}
