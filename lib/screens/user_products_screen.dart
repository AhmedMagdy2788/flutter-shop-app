import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/editUserProduct.dart';
import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products';

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  bool isLoading = true;
  bool isInit = false;
  ProductsProvider productsData;
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      productsData = Provider.of<ProductsProvider>(context);
      await productsData.fetchingData();
      setState(() {
        isLoading = false;
        isInit = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditUserProduct.namedRoute, arguments: 'new');
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: (isLoading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                await Provider.of<ProductsProvider>(context).fetchingData();
                setState(() {
                  isLoading = false;
                });
              },
              child: Visibility(
                visible: !isLoading,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: productsData.items.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        UserProductItem(
                          productsData.items[i].id,
                          productsData.items[i].title,
                          productsData.items[i].imageUrl,
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
