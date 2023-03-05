import 'package:solidtrade/data/models/common/quotes/quote_category.dart';
import 'package:solidtrade/data/models/enums/client_enums/lang_ticker.dart';

class Quote {
  final LanguageTicker lang;
  final String quote;
  final QuoteCategory category;

  Quote({required this.lang, required this.quote, required this.category});
}
