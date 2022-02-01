import 'package:flutter/material.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({Key? key, required this.info}) : super(key: key);
  final ProductTileInfo info;

  // Use trade republic api
  // Create a singelton service for the connection
  // Create a transient to communicate to the singleton
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("test"),
    );
  }
}
