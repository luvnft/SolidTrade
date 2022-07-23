import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/common/prevent_render_flex_overflow_wrapper.dart';
import 'package:solidtrade/pages/search/components/learn_the_basics.dart';
import 'package:solidtrade/pages/search/components/search_categories.dart';
import 'package:solidtrade/services/util/extensions/build_context_extensions.dart';

class SearchPage extends StatelessWidget with STWidget {
  SearchPage({Key? key}) : super(key: key);

  Text _constructTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, _) => Container(
        margin: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Text(
              "Browse",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                // color: colors.background,
                color: colors.softBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.foreground, width: 2),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.search,
                      size: 20,
                      color: colors.foreground,
                    ),
                    SizedBox(
                      width: constraints.maxWidth - 30,
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          hintText: 'Search companies...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: colors.foreground),
                        ),
                        style: TextStyle(fontSize: 16, color: colors.foreground),
                        onChanged: _handleChangeSearch,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: PreventColumnRenderFlexOverflowWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _constructTitle("Popular categories"),
                    const SizedBox(height: 10),
                    SearchCategories(onPressCategory: _handlePressCategory),
                    const SizedBox(height: 20),
                    _constructTitle("Learn the basics"),
                    const SizedBox(height: 10),
                    const LearnTheBasics(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChangeSearch(String input) {}
  void _handlePressCategory(String category) {}
}
