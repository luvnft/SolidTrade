import 'package:solidtrade/data/models/common/quotes/quote.dart';
import 'package:solidtrade/data/models/common/quotes/quote_category.dart';
import 'package:solidtrade/data/models/common/quotes/quotes.dart';
import 'package:solidtrade/data/models/enums/client_enums/lang_ticker.dart';

class SharedQuotesTranslations {
  static final Map<String, List<Quote>> _cachedQuotes = {};

  static String getRandomQuote(LanguageTicker lang, QuoteCategory category) {
    var cacheId = _createCacheIdentifier(lang, category);

    if (!_cachedQuotes.containsKey(cacheId)) {
      var filteredQuotes = _getFilteredQuotes(lang, category);
      _cachedQuotes[cacheId] = filteredQuotes;
    }

    var quotes = _cachedQuotes[cacheId]!;

    quotes.shuffle();
    return quotes.first.quote;
  }

  static List<Quote> _getFilteredQuotes(LanguageTicker lang, QuoteCategory category) {
    return Quotes.quotes.where((quote) => quote.lang == lang && quote.category == category).toList();
  }

  static String _createCacheIdentifier(LanguageTicker ticker, QuoteCategory category) => "$ticker-$category";
}
