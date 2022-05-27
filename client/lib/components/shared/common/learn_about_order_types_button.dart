import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnAboutOrderTypesButton extends StatelessWidget with STWidget {
  LearnAboutOrderTypesButton({Key? key}) : super(key: key);

  void _onClickLearnAboutOrderTypes() => launch(Constants.learnMoreAboutOrderTypesLink);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onClickLearnAboutOrderTypes,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info, size: 25),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Tip: Want to learn more about order types?",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}
