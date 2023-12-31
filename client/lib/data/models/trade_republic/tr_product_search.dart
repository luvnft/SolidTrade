import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class TrProductSearch {
  final List<TrProductSearchResult> results;
  final int resultCount;

  TrProductSearch(this.results, this.resultCount);
}

@jsonSerializable
class TrProductSearchResult {
  final String isin;
  final String name;
  final String type;
  final List<String> derivativeProductCategories;
  final List<TrProductSearchTags> tags;

  TrProductSearchResult(this.isin, this.name, this.type, this.derivativeProductCategories, this.tags);
}

@jsonSerializable
class TrProductSearchTags {
  final String id;
  final String name;
  final String type;

  const TrProductSearchTags(this.id, this.name, this.type);
}
