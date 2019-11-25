import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_item_widget.dart';
import '../providers/orders_provider.dart' show Orders;

class OrdersScreen extends StatelessWidget {
  static String namedRoot = '/Order_screen';
  // @override
  // void initState() {
  //   Future.delayed(Duration.zero, () {
  //     orderData = Provider.of<Orders>(context);
  //     orderData.fatchUserOrders();
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fatchUserOrders(),
        builder: (ctx, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
              onRefresh: () =>
                  Provider.of<Orders>(context, listen: false).fatchUserOrders(),
              child: Consumer<Orders>(
                builder: (_ctx, orderData, child) {
                  return ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) =>
                        OrderItemWidget(orderData.orders[i]),
                  );
                },
              ),
            );
          }
          return Center(
            child: Text('Error loading..'),
          );
        },
      ),
    );
  }
}
