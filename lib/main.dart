import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/splash-screen.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/editUserProduct.dart';
import 'screens/order_screen.dart';
import 'screens/auth-screen.dart';
import 'screens/peoducts_overview.dart';
import 'screens/product_details.dart';
import 'screens/user_products_screen.dart';
import 'models/cart.dart';

void main() => runApp(MyApp());

//https://flutter-shop-app-31c34.firebaseio.com/
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (ctx) => ProductsProvider(null, null, false),
          update: (ctx, authProvider, previousProduct) =>
              ProductsProvider(authProvider.token, authProvider.userID, false),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Cart>(
          create: (ctx) => Cart(null),
          update: (ctx, auth, previousCart) => Cart(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Orders>(
          create: (ctx) => Orders(null, null),
          update: (ctx, auth, previousOrders) =>
              Orders(auth.token, auth.userID),
        )
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop App',
            theme: ThemeData(
              fontFamily: 'Lato',
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                  .copyWith(secondary: Colors.deepOrange),
            ),
            home: authProvider.isAuthenticated
                ? ProductsOverview()
                : FutureBuilder(
                    future: authProvider.tryAutoLogin(),
                    builder: (ctx, boolFutureSnapshot) {
                      return (boolFutureSnapshot.connectionState ==
                              ConnectionState.waiting)
                          ? SplashScreen()
                          : AuthScreen();
                    },
                  ),
            routes: {
              AuthScreen.routeName: (ctx) => AuthScreen(),
              ProductsOverview.routeName: (ctx) => ProductsOverview(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.nameRout: (ctx) => CartScreen(),
              OrdersScreen.namedRoot: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditUserProduct.namedRoute: (ctx) => EditUserProduct(),
            },
          );
        },
      ),
    );
  }
}
