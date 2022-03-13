import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/services/util/util.dart';

class BrokenImplicitScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that does not let the user scroll.
  const BrokenImplicitScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BrokenImplicitScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool get allowImplicitScrolling => false;
}

class LoginScreen extends StatelessWidget with STWidget {
  LoginScreen({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.imageUrl,
    this.additionalWidgets,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final String imageUrl;
  final List<Widget>? additionalWidgets;

  List<Widget> getTitleContent(BoxConstraints constraints, BuildContext context) {
    return [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          subTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
        physics: const BrokenImplicitScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .88,
          ),
          child: Column(
            children: [
              Util.loadImage(
                imageUrl,
                constraints.maxWidth,
                borderRadius: BorderRadius.circular(25),
                boxFit: BoxFit.cover,
                loadingBoxShape: BoxShape.rectangle,
              ),
              const SizedBox(height: 20),
              ...getTitleContent(constraints, context),
              const Spacer(),
              ...[
                ...additionalWidgets ??
                    [
                      const SizedBox.shrink()
                    ],
                const SizedBox(height: 15),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
