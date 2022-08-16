import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_page.dart';
import 'package:solidtrade/components/base/st_widget.dart';
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
              _SearchResults(textEditingController: _textEditingController)
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

// https://www.youtube.com/watch?v=ZtfItHwFlZ8
class _SearchResults extends StatefulWidget {
  const _SearchResults({Key? key, required this.textEditingController}) : super(key: key);
  final TextEditingController textEditingController;

  @override
  State<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<_SearchResults> {
  final TrProductSearchService _trProductSearchService = GetIt.instance.get<TrProductSearchService>();
  String _previousSearch = "";

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(_onSearchChanged);
  }

  Future<void> _onSearchChanged() async {
    var search = widget.textEditingController.value.text;
    if (search == _previousSearch) return;

    _previousSearch = search;

    var result = await _trProductSearchService.requestTrProductSearch("Tesla");
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // child: Text("Search: " + _searchInput),
      child: Text("Search: "),
    );
  }
}

class SingleSearchResult extends StatelessWidget {
  const SingleSearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
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
