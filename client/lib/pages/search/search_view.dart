import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_page.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/models/trade_republic/tr_product_search.dart';
import 'package:solidtrade/pages/search/components/search_input_field.dart';
import 'package:solidtrade/services/stream/tr_product_search_service.dart';
import 'package:solidtrade/services/util/extensions/build_context_extensions.dart';

class SearchView extends StatefulWidget {
  const SearchView({
    Key? key,
    required this.child,
    required this.inputFieldHeroTag,
  }) : super(key: key);
  final String inputFieldHeroTag;
  final Widget child;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with STWidget {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return STPage(
      page: () => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Hero(
                tag: widget.inputFieldHeroTag,
                child: Container(
                  height: 70,
                  width: double.infinity,
                  color: colors.softBackground,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: context.screenWidth * 0.5,
                      child: SearchInputField(
                        autofocus: true,
                        leftPadding: const SizedBox(width: 0),
                        textEditingController: _textEditingController,
                        customLeadingWidget: _CustomIconButton(
                          onPressed: () => Navigator.pop(context),
                          width: 50,
                          icon: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: colors.foreground,
                          ),
                        ),
                        customActionWidget: _CustomIconButton(
                          onPressed: _onClickClearInput,
                          width: 50,
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: colors.foreground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _SearchResults(
                  textEditingController: _textEditingController,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onClickClearInput() {
    _textEditingController.clear();
  }
}

class _SearchResults extends StatefulWidget {
  const _SearchResults({Key? key, required this.textEditingController}) : super(key: key);
  final TextEditingController textEditingController;

  @override
  State<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<_SearchResults> {
  final _trProductSearchService = GetIt.instance.get<TrProductSearchService>();
  final List<TrProductSearchResult> _productSearchResults = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();

  String _previousSearch = "_";

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(_onSearchChanged);
  }

  Widget _buildItem(TrProductSearchResult result, Animation<double> animation) {
    // var tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).chain(
    //   CurveTween(curve: Curves.ease),
    // );
    var tween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.ease),
    );

    return FadeTransition(
      opacity: animation.drive(tween),
      child: SingleSearchResult(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedList(
        key: _animatedListKey,
        initialItemCount: _productSearchResults.length,
        itemBuilder: (context, index, animation) => _buildItem(_productSearchResults[index], animation),
      ),
    );
  }

  Future<void> _onSearchChanged() async {
    var search = widget.textEditingController.value.text;
    if (search == _previousSearch) return;

    _previousSearch = search;

    var searchResult = await _fetchSearchResults(search);
    _updateResults(searchResult);
  }

  Future<TrProductSearch> _fetchSearchResults(String search) async {
    var result = await _trProductSearchService.requestTrProductSearch(search);
    if (result.isSuccessful) {
      return result.result!;
    }

    throw UnimplementedError();
  }

  void _updateResults(TrProductSearch searchResult) {
    void insertItem(int destIndex, TrProductSearchResult item) {
      _productSearchResults.insert(destIndex, item);
      _animatedListKey.currentState?.insertItem(destIndex);
    }

    void removeItem(int targetIndex) {
      var item = _productSearchResults.removeAt(targetIndex);
      _animatedListKey.currentState?.removeItem(
        targetIndex,
        (context, animation) => _buildItem(item, animation),
        duration: Duration.zero,
      );
    }

    void replace(int targetIndex, TrProductSearchResult item) {
      removeItem(targetIndex);
      insertItem(targetIndex, item);
    }

    for (int index = 0; index < searchResult.results.length; index++) {
      if (_productSearchResults.length != index && searchResult.results[index].name != _productSearchResults[index].name) {
        replace(index, searchResult.results[index]);
        continue;
      }

      insertItem(index, searchResult.results[index]);
    }

    for (var i = searchResult.results.length; i < _productSearchResults.length; i++) {
      removeItem(i--);
    }
  }
}

class SingleSearchResult extends StatelessWidget {
  const SingleSearchResult({Key? key, required this.result}) : super(key: key);
  final TrProductSearchResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Center(
        child: Text(result.name),
      ),
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  const _CustomIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.width,
  }) : super(key: key);
  final void Function()? onPressed;
  final double width;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      alignment: Alignment.center,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(width, double.infinity),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
        ),
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: icon,
        ),
      ),
    );
  }
}
