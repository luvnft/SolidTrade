import 'package:solidtrade/data/models/common/quotes/quote.dart';
import 'package:solidtrade/data/models/common/quotes/quote_category.dart';
import 'package:solidtrade/data/models/enums/client_enums/lang_ticker.dart';

class Quotes {
  static List<Quote> quotes = [
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'Funding secured😎'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'Buy High Sell Low. Right?'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'GME to the moon🚀'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'TSLA to the moon🚀'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'A wise man once said with wisdom comes 100X leverage🚀'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'Why buy ETFs if you can buy Knockouts with 100X leverage🤷‍♂️'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: "What is a Margin Call and why can't I buy more TSLA?!"),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'The Big Long🚀'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'Some people are actually making money in the stock market?'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'My portfolio is doing better than usual today\n Meanwhile, Portfolio down 70%'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'Anyone knows a Trade Republic money glitch?'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: 'With great leverage comes greater profits. Technically...'),
    Quote(category: QuoteCategory.splashScreen, lang: LanguageTicker.en, quote: "Ever heard of technical analysis? It's pretty much astrology for men. Try it!"),
    Quote(category: QuoteCategory.knockout, lang: LanguageTicker.en, quote: '10x to the moon 🚀🌑 or lose it all'),
    Quote(category: QuoteCategory.warrant, lang: LanguageTicker.en, quote: '🧐 Analysts recommend warrants with 5 DTE'),
    Quote(category: QuoteCategory.knockout, lang: LanguageTicker.de, quote: '10x zum Mond 🚀🌑 oder alles verlieren'),
    Quote(category: QuoteCategory.warrant, lang: LanguageTicker.de, quote: 'Analysten empfehlen Optionsscheine über Aktien'),
  ];
}
