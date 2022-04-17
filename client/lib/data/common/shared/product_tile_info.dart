import 'package:solidtrade/data/enums/position_type.dart';

class ProductTileInfo {
  final PositionType positionType;
  final String isin;

  ProductTileInfo(this.positionType, this.isin);
}
