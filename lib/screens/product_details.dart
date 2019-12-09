import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isExpanded = false;
  Product _product;
  @override
  Widget build(BuildContext context) {
    final routArg =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    _product = routArg[Product.nameArg];
    return Scaffold(
      appBar: AppBar(
        title: Text(_product.title),
      ),
      body: buildProductDetailsBody(context),
    );
  }

  Widget buildProductDetailsBody(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SingleChildScrollView(
          child: Container(
            width: constraints.maxWidth,
            height:
                (isExpanded) ? constraints.maxHeight : constraints.maxHeight,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Hero(
                        tag: _product.id,
                        child: Image.network(
                          _product.imageUrl,
                          height: (isExpanded)
                              ? constraints.maxHeight * 0.50
                              : constraints.maxHeight,
                          width: constraints.maxWidth,
                          fit: (!isExpanded) ? BoxFit.cover : BoxFit.scaleDown,
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight * 0.5,
                          child: buildDetaolsContainerWidget(
                            context,
                            constraints.maxHeight * 0.5,
                            constraints.maxWidth,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isExpanded)
                  Positioned(
                    bottom: constraints.maxWidth * 0.025,
                    right: constraints.maxWidth * 0.025,
                    child: Container(
                      width: constraints.maxWidth * 0.75,
                      height: constraints.maxHeight * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(constraints.maxWidth * 0.05),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              spreadRadius: 5)
                        ],
                      ),
                      child: buildDetaolsContainerWidget(
                          context,
                          constraints.maxHeight * 0.40,
                          constraints.maxWidth * 0.75),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDetaolsContainerWidget(
      BuildContext context, double height, double width) {
    // print('argWidth = $width');
    // print('argHeight = $height');
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // print('constraintsWidth = ${constraints.maxWidth}');
        // print('constraintsHeight = ${constraints.maxHeight}');
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: constraints.maxWidth * 0.1,
                  ),
                  Text(
                    'Details',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    icon: Icon(
                      (isExpanded) ? Icons.expand_less : Icons.expand_more,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    buildDetailsRowWidget(
                        context, constraints, 'Title: ', _product.title),
                    buildDetailsRowWidget(context, constraints, 'Price: ',
                        _product.price.toStringAsFixed(2)),
                    Container(
                      padding: EdgeInsets.only(
                          left: constraints.maxWidth * 0.1,
                          bottom: constraints.maxWidth * 0.05),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Description: ',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _product.description,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget buildDetailsRowWidget(BuildContext context, BoxConstraints constraints,
      String title, String details) {
    return Padding(
      padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.1,
          bottom: constraints.maxWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              details,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
