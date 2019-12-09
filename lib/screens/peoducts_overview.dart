import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../widgets/product_item_widget.dart';

enum MenuSelectedValues {
  Favourites,
  All,
}

class ProductsOverview extends StatefulWidget {
  static String routeName = '/productsOverview';
  @override
  _ProductsOverviewState createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {
  bool isFavouritesOnly = false;
  bool isLoading = true;
  ProductsProvider productProvider;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      productProvider = Provider.of<ProductsProvider>(context);
      await productProvider.fetchingData();
      setState(() {
        isLoading = false;
        // isInit = true;
      });
    });
    // .then(
    //   // (onValue) {
    // //   productProvider = Provider.of<ProductsProvider>(context);
    // //   if (!productProvider.isDataFetched) {
    // //     fitchData(context);
    // //   } else
    // //     setState(() {
    // //       isLoading = false;
    // //     });
    // // }
    // );
    super.initState();
  }

  Future<void> fitchData(BuildContext context) async {
    productProvider.fetchingData().then((_) {
      productProvider.isDataFetched = true;
      setState(() {
        isLoading = false;
      });
      print('fitching seccess here');
    }).catchError((onError) {
      print(onError.toString());
      setState(() {
        isLoading = false;
      });
      //   Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text(onError.toString()),
      //   action: SnackBarAction(
      //     label: 'retry',
      //     onPressed: () => fitchData,
      //   ),
      //   duration: Duration(seconds: 1),
      // ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products Overview'),
        actions: <Widget>[
          Consumer<Cart>(
            builder: (_ctx, cart, _child) => Badge(
              child: _child,
              value: cart.itemsCount.toString(),
              color: Theme.of(context).accentColor,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.nameRout);
              },
              color: Colors.white,
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (MenuSelectedValues selectedValue) {
              setState(() {
                switch (selectedValue) {
                  case MenuSelectedValues.Favourites:
                    isFavouritesOnly = true;
                    break;
                  default:
                    isFavouritesOnly = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Favourites only'),
                value: MenuSelectedValues.Favourites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: MenuSelectedValues.All,
              ),
            ],
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
                  child: ProductsGridViewWidget(isFavouritesOnly)),
            ),
    );
  }
}

class ProductsGridViewWidget extends StatelessWidget {
  final bool isFavouritesOnly;
  ProductsGridViewWidget(this.isFavouritesOnly);
  @override
  Widget build(BuildContext context) {
    ProductsProvider productsProvider = Provider.of<ProductsProvider>(context);
    List<Product> productsList = (isFavouritesOnly)
        ? productsProvider.favouritesItems
        : productsProvider.items;
    return LayoutBuilder(builder: (ctx, constrains) {
      return Container(
        width: constrains.maxWidth,
        height: constrains.maxHeight,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(constrains.maxWidth * 0.025),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              mainAxisSpacing: constrains.maxWidth * 0.025,
              crossAxisSpacing: constrains.maxWidth * 0.025),
          itemBuilder: (ctx, index) {
            return ChangeNotifierProvider.value(
                value: productsList[index], child: ProductItemWidget());
          },
          itemCount: productsList.length,
        ),
      );
    });
  }
}
