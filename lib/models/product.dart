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
  bool favourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.favourite = false,
  });

  String toJSON() {
    return convert.json.encode({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'favourite': favourite,
    });
  }

  Future<void> toggleFavorite() async {
    this.favourite = !this.favourite;
    notifyListeners();
    var respoce = await http.patch(
        'https://flutter-shop-app-31c34.firebaseio.com/products/${this.id}.json',
        body: convert.json.encode({
          'favourite': this.favourite,
        }));
    if (respoce.statusCode >= 400) {
      this.favourite = !this.favourite;
      notifyListeners();
    } else {
      // notifyListeners();
      print('toggle Favorites of $title');
    }
  }
}
