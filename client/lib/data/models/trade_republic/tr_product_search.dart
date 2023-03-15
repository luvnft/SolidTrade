import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class TrProductSearch {
  final List<TrProductSearchResult> results;
  final int resultCount;

  TrProductSearch({
    required this.results,
    required this.resultCount,
  });
}

@jsonSerializable
class TrProductSearchResult {
  final String isin;
  final String name;
  final String type;
  final List<String> derivativeProductCategories;
  final List<TrProductSearchTags> tags;

  TrProductSearchResult({
    required this.isin,
    required this.name,
    required this.type,
    required this.derivativeProductCategories,
    required this.tags,
  });
}

@jsonSerializable
class TrProductSearchTags {
  final String id;
  final String name;
  final String type;

  const TrProductSearchTags({
    required this.id,
    required this.name,
    required this.type,
  });
}
