import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../providers/orders_provider.dart';
import '../screens/order_screen.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  static String nameRout = '/cartScreen';
  CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Cart _cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cart',
          // style: Theme.of(context).textTheme.title,
        ),
      ),
      body: buildCartScreenBody(context, _cart),
    );
  }

  Widget buildCartScreenBody(BuildContext context, Cart cart) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            children: <Widget>[
              buildCartHeader(
                  context,
                  cart,
                  BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.1,
                      maxWidth: constraints.maxWidth)),
              buildCartProductsList(
                  context,
                  cart,
                  BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.9,
                      maxWidth: constraints.maxWidth)),
            ],
          ),
        );
      },
    );
  }

  Widget buildCartHeader(
      BuildContext context, Cart cart, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: constraints.maxWidth * 0.05,
          ),
          Text(
            'Total',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Container(
            // padding: EdgeInsets.all(constraints.maxHeight * 0.0025),
            // margin: EdgeInsets.all(constraints.maxHeight * 0.0025),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(constraints.maxHeight / 2),
                border: Border.all(
                    color: Theme.of(context).colorScheme.secondary, width: 2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                FittedBox(
                  child: Text(
                    '\$ ${cart.totalCartPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  child: Text(
                    'ORDER NOW',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary),
                  onPressed: (isLoading || cart.cartItems.length <= 0)
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          await Provider.of<Orders>(context, listen: false)
                              .addOrder(cart.cartItems, cart.totalCartPrice);
                          setState(() {
                            isLoading = false;
                          });
                          cart.clear();
                          Navigator.of(context)
                              .pushReplacementNamed(OrdersScreen.namedRoot);
                        },
                )
              ],
            ),
          ),
          SizedBox(
            width: constraints.maxWidth * 0.05,
          ),
        ],
      ),
    );
  }

  Widget buildCartProductsList(
      BuildContext context, Cart cart, BoxConstraints constraints) {
    return Expanded(
      child: ListView.builder(
        itemCount: cart.cartItems.length,
        itemBuilder: (ctx, index) {
          return CartItemWidget(cart.cartItems[index]);
        },
      ),
    );
  }
}
