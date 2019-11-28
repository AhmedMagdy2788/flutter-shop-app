import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../models/http_exception.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  final String token;
  final String userID;
  bool isDataFetched;
  ProductsProvider(this.token, this.userID, this.isDataFetched);
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  List<Product> _userProduct = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get userProduct {
    return [..._userProduct];
  }


  List<Product> get favouritesItems {
    return _items.where((productItem) {
      return productItem.favourite;
    }).toList();
  }

  Future<void> fetchUserCreatedProduct() async {
    print('fetching user created product');
    var response = await http.get(
        'https://flutter-shop-app-31c34.firebaseio.com/products.json?auth=$token&orderBy="ownerID"&equalTo="$userID"');
    var responseData =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
        
    List<Product> recvedProductList = [];
    responseData.forEach((prodID, prodData) {
      recvedProductList.add(Product(
        id: prodID,
        title: prodData['title'],
        description: prodData['description'],
        price: prodData['price'],
        imageUrl: prodData['imageUrl'],
        ownerID: prodData['ownerID'],
      ));
    });
    print('num of products = ${recvedProductList.length}');
    _userProduct = recvedProductList;
    notifyListeners();
  }

  Future<void> fetchingData([bool filtered = false]) async {
    print('Fitching data from server');
    // try {
    String filteredExtention =
        filtered ? '&orderBy="ownerID"&equelTo="$userID"' : '';
    var response = await http.get(
        'https://flutter-shop-app-31c34.firebaseio.com/products.json?auth=$token$filteredExtention');
    // try {
    var fitchedProductsData =
        convert.json.decode(response.body) as Map<String, dynamic>;
    print('Data Fitched Succefully');
    // try {
    print(userID);
    response = await http.get(
        'https://flutter-shop-app-31c34.firebaseio.com/userFavouritesProducts/$userID.json?auth=$token');
    // try {
    var favouriteProductsData = convert.json.decode(response.body);
    print('Data Fitched Succefully');
    List<Product> recvedProductList = [];
    fitchedProductsData.forEach((prodID, prodData) {
      // if (!_items.any((prod) {
      //   if (prodID == prod.id) return true;
      //   return false;
      // }))
      recvedProductList.add(Product(
        id: prodID,
        title: prodData['title'],
        description: prodData['description'],
        price: prodData['price'],
        imageUrl: prodData['imageUrl'],
        favourite: (favouriteProductsData == null)
            ? false
            : favouriteProductsData[prodID] ?? false,
        ownerID: prodData['ownerID'],
      ));
    });
    _items = recvedProductList;
    // print(fitchedData.toString());
    notifyListeners();
    // } catch (error) {
    //   print('Formating error');
    // }
    // } catch (error) {
    //   print('fitching from server error');
    // }
  }

  Future<void> addProduct(Product product) {
    return http
        .post(
            'https://flutter-shop-app-31c34.firebaseio.com/products.json?auth=$token',
            body: product.toJSON())
        .then((responce) {
      _items.add(Product(
        id: convert.json.decode(responce.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        ownerID: product.ownerID,
      ));
      notifyListeners();
    }).catchError((error) {
      print(error.toString());
      throw (error);
    });
  }

  Future<void> editProduct(String prodID, Product product) async {
    try {
      var index = _items.indexOf(_items.firstWhere((prod) {
        if (prod.id == prodID) {
          return true;
        }
        return false;
      }));
      http.patch(
          'https://flutter-shop-app-31c34.firebaseio.com/products/$prodID.json?auth=$token',
          body: product.toJSON());
      _items[index] = Product(
        id: prodID,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        description: product.description,
        ownerID: product.ownerID,
      );
      notifyListeners();
    } catch (onError) {
      print(onError.toString());
    }
  }

  Future<void> removeProduct(String prodID) async {
    final existingProductIndex = _items.indexWhere((prod) {
      if (prod.id == prodID) {
        return true;
      }
      return false;
    });
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    var responce = await http.delete(
        'https://flutter-shop-app-31c34.firebaseio.com/products/$prodID.json?auth=$token');
    if (responce.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw (HttpException(
          'delete ${existingProduct.title} failed with code ${responce.statusCode}'));
    } else {
      existingProduct = null;
    }
  }
}
