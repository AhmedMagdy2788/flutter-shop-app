import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import '../providers/products_provider.dart';

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;

  OrderItemWidget(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItemWidget>
    with SingleTickerProviderStateMixin {
  var _expanded = false;
  bool _isInit = false;
  late AnimationController _animeController;
  late Animation<double> _fadeAnimation;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _animeController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animeController, curve: Curves.easeIn));
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                  if (_expanded)
                    _animeController.forward();
                  else
                    _animeController.reverse();
                });
              },
            ),
          ),
          // if (_expanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: _expanded
                ? min(widget.order.products.length * 20.0 + 10, 100)
                : 0,
            // height: 500,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                children: widget.order.products
                    .map(
                      (prod) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            Provider.of<ProductsProvider>(context)
                                .items
                                .firstWhere((product) {
                              if (product.id == prod.productID)
                                return true;
                              else
                                return false;
                            }).title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${prod.productAmount.toString()}x \$${prod.productPrice.toString()}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
