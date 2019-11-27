import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';

import '../models/product.dart';
import '../providers/products_provider.dart';

class EditUserProduct extends StatefulWidget {
  static String namedRoute = '/EditUserProductsScreen';
  // final String userID;
  EditUserProduct({Key key}) : super(key: key);

  @override
  _EditUserProductState createState() => _EditUserProductState();
}

class _EditUserProductState extends State<EditUserProduct> {
  FocusNode _priceFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _imageUrlFocusNode = FocusNode();
  TextEditingController _imageUrlController = TextEditingController();
  GlobalKey<FormState> _productFormKey = GlobalKey<FormState>();
  String _userID;
  String _productID;
  String _productTitle = '';
  double _productPrice = 0.0;
  String _productDescription = '';
  String _productURL = '';
  bool _isInit = false;
  bool _isNew = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_imageUrlFocusNodeListner);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _userID = Provider.of<AuthProvider>(context, listen: false).userID;
      _productID = ModalRoute.of(context).settings.arguments as String;
      if (_productID != 'new') {
        _isNew = false;
        Product product =
            Provider.of<ProductsProvider>(context).items.firstWhere((prod) {
          if (prod.id == _productID) return true;
          return false;
        });
        _productTitle = product.title;
        _productPrice = product.price;
        _productDescription = product.description;
        _productURL = product.imageUrl;
        _imageUrlController.text = _productURL;
      }
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_imageUrlFocusNodeListner);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _imageUrlFocusNodeListner() {
    if (!_imageUrlFocusNode.hasFocus) setState(() {});
  }

  void _saveProductForm(BuildContext context) {
    bool isValidForm = _productFormKey.currentState.validate();
    if (!isValidForm) return;
    _productFormKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_isNew){
      Provider.of<ProductsProvider>(context)
          .addProduct(Product(
        id: _productID,
        title: _productTitle,
        description: _productDescription,
        price: _productPrice,
        imageUrl: _productURL,
        ownerID: _userID,
      ))
          .catchError((error) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Server Error'),
                content:
                    Text('Check Internet conection or contect your server'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }).then((onValue) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }else {
      Provider.of<ProductsProvider>(context).editProduct(
          _productID,
          Product(
            id: _productID,
            title: _productTitle,
            description: _productDescription,
            price: _productPrice,
            imageUrl: _productURL,
            ownerID: _userID,
          ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adding new product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () => _saveProductForm(context),
          )
        ],
      ),
      body: Center(
        child: (_isLoading)
            ? CircularProgressIndicator()
            : buildAddingFormWidget(context),
      ),
    );
  }

  Widget buildAddingFormWidget(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          child: Form(
              key: _productFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: (_isNew) ? null : _productTitle,
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_fieldValue) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _productTitle = value;
                      },
                    ),
                    TextFormField(
                      initialValue: (_isNew) ? null : _productPrice.toString(),
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _productPrice = double.parse(value);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please Enter valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please Enter price greater than zero';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: (_isNew) ? null : _productDescription,
                      decoration: InputDecoration(labelText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter Description for the product';
                        }
                        if (value.length < 10) {
                          return 'Please Enter Description more than 10 char';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _productDescription = value;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10, top: 10, left: 10),
                          alignment: Alignment.center,
                          width: constraints.maxWidth * 0.3,
                          height: constraints.maxWidth * 0.3,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: FittedBox(
                            child: _imageUrlController.text.isEmpty
                                ? Text('No URL')
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Imag URL'),
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            controller: _imageUrlController,
                            onFieldSubmitted: (_) {
                              _saveProductForm(context);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter image url';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _productURL = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
