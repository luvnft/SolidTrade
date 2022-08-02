import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/pages/search/components/search_input_field.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        onPressed: () => Navigator.pop(context),
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
            const _SearchResult()
          ],
        ),
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("data"),
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
