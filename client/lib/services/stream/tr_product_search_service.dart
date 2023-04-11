// TODO: Remove commented code if everything works fine
// import 'package:rxdart/subjects.dart';
// import 'package:solidtrade/data/models/common/constants.dart';
// import 'package:solidtrade/data/models/request_response/request_response.dart';
// import 'package:solidtrade/data/models/trade_republic/tr_product_search.dart';
// import 'package:solidtrade/services/request/data_request_service.dart';
// import 'package:solidtrade/services/stream/base/base_service.dart';

// class TrProductSearchService extends IService<Map<SearchType, RequestResponse<TrProductSearch>>?> {
//   TrProductSearchService() : super(BehaviorSubject.seeded(null));
//   final Map<String, Map<SearchType, RequestResponse<TrProductSearch>>> _cache = {};

//   Future<Map<SearchType, RequestResponse<TrProductSearch>>> requestTrProductSearch(String search) async {
//     Map<SearchType, RequestResponse<TrProductSearch>> results;
//     if (_cache.containsKey(search)) {
//       results = (_cache[search]!);
//     } else {
//       var stocksFuture = DataRequestService.trApiDataRequestService.makeRequest<TrProductSearch>(Constants.getTrProductSearchRequestString(
//         search,
//         SearchType.stock.name,
//       ));

//       var cryptosFuture = DataRequestService.trApiDataRequestService.makeRequest<TrProductSearch>(Constants.getTrProductSearchRequestString(
//         search,
//         SearchType.crypto.name,
//       ));

//       var derivativesFuture = DataRequestService.trApiDataRequestService.makeRequest<TrProductSearch>(Constants.getTrProductSearchRequestString(
//         search,
//         SearchType.derivatives.name,
//       ));

//       var fundsFuture = DataRequestService.trApiDataRequestService.makeRequest<TrProductSearch>(Constants.getTrProductSearchRequestString(
//         search,
//         SearchType.fund.name,
//       ));

//       await Future.wait([
//         stocksFuture,
//         cryptosFuture,
//         derivativesFuture,
//         fundsFuture
//       ]);

//       results = {
//         SearchType.stock: await stocksFuture,
//         SearchType.crypto: await cryptosFuture,
//         SearchType.derivatives: await derivativesFuture,
//         SearchType.fund: await fundsFuture,
//       };

//       _cache[search] = results;
//     }

//     behaviorSubject.add(results);
//     return results;
//   }
// }

// enum SearchType {
//   stock,
//   crypto,
//   fund,
//   derivatives
// }

import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/data/models/request_response/request_response.dart';
import 'package:solidtrade/data/models/trade_republic/tr_product_search.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';

class TrProductSearchService extends IService<TrProductSearch?> {
  TrProductSearchService() : super(BehaviorSubject.seeded(null));
  final Map<String, TrProductSearch> _cache = {};

  Future<RequestResponse<TrProductSearch>> requestTrProductSearch(SearchCategory category, String search) async {
    RequestResponse<TrProductSearch>? result;
    if (_cache.containsKey(search)) {
      result = RequestResponse.successful(_cache[search]!);
    } else {
      result = await DataRequestService.trApiDataRequestService.makeRequest<TrProductSearch>(Constants.getTrProductSearchRequestString(
        search,
        category.name,
      ));

      if (result.isSuccessful) {
        _cache[search] = result.result!;
      }
    }

    if (result.isSuccessful) {
      behaviorSubject.add(result.result);
    }

    return result;
  }
}

enum SearchCategory {
  stock,
  crypto,
  fund,
  derivative
}
