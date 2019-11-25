import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/order.dart';

class Orders with ChangeNotifier {
  final String token;
  Orders(this.token);
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fatchUserOrders() async {
    var response = await http
        .get('https://flutter-shop-app-31c34.firebaseio.com/orders.json?auth=$token');
        // print(convert.jsonDecode(response.body));
    Map<String, dynamic> ordersData =
        convert.json.decode(response.body) as Map<String, dynamic>;
    List<OrderItem> orderItemsList = [];
    ordersData.forEach((orderItemID, orderItemData) {
      orderItemsList.add(OrderItem(
        id: orderItemID,
        amount: orderItemData['amount'],
        dateTime: DateTime.parse(orderItemData['dateTime']),
        products: (orderItemData['products'] as List< dynamic>)
          .map((listItem){
            return CartItem(
              id: listItem['id'],
              title: listItem['title'],
              productID: listItem['productID'],
              productPrice: listItem['price'],
              productAmount: listItem['amount'],
            );
          }).toList(),
      ));
    });
    _orders = orderItemsList;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var date = DateTime.now().toIso8601String();
    var response = await http.post(
        'https://flutter-shop-app-31c34.firebaseio.com/orders.json?auth=$token',
        body: convert.json.encode({
          'amount': total,
          'dateTime': date,
          'products': cartProducts.map((cartItem) {
            return {
              'id':cartItem.id,
              'title': cartItem.title,
              'productID': cartItem.productID,
              'amount': cartItem.productAmount,
              'price': cartItem.productPrice,
            };
          }).toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: convert.json.decode(response.body)['name'],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
