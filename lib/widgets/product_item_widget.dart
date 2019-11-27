import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../screens/product_details.dart';
import 'badge.dart';

class ProductItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Product _product = Provider.of<Product>(context, listen: false);
    AuthProvider _auther = Provider.of<AuthProvider>(context, listen: false);
    Cart _cart = Provider.of<Cart>(context, listen: false);
    return LayoutBuilder(
      builder: (ctx, constrains) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: {Product.nameArg: _product});
          },
          child: Container(
            margin: EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(constrains.maxWidth * 0.1),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 1, spreadRadius: 1)
              ],
            ),
            child: GridTile(
              footer: Container(
                height: constrains.maxHeight * 0.4,
                alignment: Alignment.center,
                padding: EdgeInsets.all(constrains.maxWidth * 0.003125),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(constrains.maxWidth * 0.1),
                    bottomRight: Radius.circular(constrains.maxWidth * 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Consumer<Product>(
                      builder: (ctx, product, child) => IconButton(
                        icon: Icon(
                          (product.favourite)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: () {
                          product.toggleFavorite(_auther.userID, _auther.token);
                        },
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _product.title,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                      ),
                    ),
                    Consumer<Cart>(
                      builder: (_ctx, _cart, _child) => Badge(
                        child: _child,
                        value: _cart.getProductAmount(_product.id).toString(),
                        color: Theme.of(context).accentColor,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _cart.addProductToCart(
                              _product.id, 1, _product.price);
                          Scaffold.of(context).hideCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${_product.title} added to the cart'),
                              action: SnackBarAction(
                                onPressed: () {
                                  _cart.removeProductItemFromCart(_product.id);
                                },
                                label: 'undo',
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(constrains.maxWidth * 0.1),
                ),
                child: Image.network(
                  _product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
