import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  CartItemWidget(this.cartItem);

  @override
  Widget build(BuildContext context) {
    Product _product =
        Provider.of<ProductsProvider>(context).items.firstWhere((product) {
      if (product.id == cartItem.productID)
        return true;
      else
        return false;
    });
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Dismissible(
          key: ValueKey(_product.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (dismissDirection) {
            return showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text('Deleting ${_product.title} from cart'),
                  content: Text(
                      'Are you sure you want to delete the ${_product.title}?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    TextButton(
                      child: Text(
                        'No',
                        style: TextStyle(color: Colors.green, fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                );
              },
            );
          },
          background: Container(
            width: constraints.maxWidth,
            height:
                (constraints.maxWidth * 0.3) - (constraints.maxWidth * 0.025),
            margin: EdgeInsets.all(constraints.maxWidth * 0.025),
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.delete,
                  size: 40,
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.025,
                ),
              ],
            ),
          ),
          onDismissed: (dirction) {
            Provider.of<Cart>(context, listen: false)
                .removeProductToCart(_product.id);
          },
          child: Container(
            width: constraints.maxWidth,
            height:
                (constraints.maxWidth * 0.5) - (constraints.maxWidth * 0.025),
            // constraints: BoxConstraints(
            //   maxHeight: constraints.maxWidth,
            //   minHeight:
            //       (constraints.maxWidth * 0.3) - (constraints.maxWidth * 0.025),
            // ),
            margin: EdgeInsets.all(constraints.maxWidth * 0.025),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(constraints.maxWidth * 0.025),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 2)
              ],
            ),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(constraints.maxWidth * 0.025),
                    bottomLeft: Radius.circular(constraints.maxWidth * 0.025),
                  ),
                  child: Image.network(
                    _product.imageUrl,
                    height: constraints.maxHeight,
                    width: constraints.maxWidth * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.025,
                ),
                Container(
                  width: constraints.maxWidth * 0.5,
                  padding: EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _product.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                      Text(
                        'Price: ${(cartItem.productPrice).toStringAsFixed(2)}\$',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        'Total: ${(cartItem.productAmount * cartItem.productPrice).toStringAsFixed(2)}\$',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: constraints.maxWidth * 0.075,
                  child: Text(
                    '${cartItem.productAmount}x',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: constraints.maxWidth * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}
