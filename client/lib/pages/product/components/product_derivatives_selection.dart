import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';

class DerivativesSelection extends StatelessWidget with STWidget {
  DerivativesSelection({Key? key, required this.productInfo}) : super(key: key);
  final TrProductInfo productInfo;
  final formatter = NumberFormat("###,###", "tr_TR");

  Widget derivativesWidget(BuildContext context, String textEmoji, String title, String subtitle, int derivativesCount) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 7.5, left: 10),
        child: Row(
          children: [
            Text(textEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(2.5),
              color: colors.blueBackground,
              child: Text(
                formatter.format(
                  derivativesCount > 10000 ? 1000 : derivativesCount,
                ),
                overflow: TextOverflow.clip,
                style: TextStyle(color: colors.blueText, fontSize: 13.5),
              ),
            ),
            const SizedBox(width: 12.5),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        productInfo.derivativeProductCount.knockOutProduct != null
            ? derivativesWidget(
                context,
                "💥",
                "Knockouts",
                // TODO: Create a list of quotes appropriate for knockouts and warrants. One quote will be randomly selected and displayed.
                // This should also be done for the splash screen. Although on the splash screen we may only support english quotes, for knockouts and warrants
                // we support multiple languages.
                "10x to the moon 🚀🌑 or lose it all.",
                productInfo.derivativeProductCount.knockOutProduct!,
              )
            : const SizedBox.shrink(),
        productInfo.derivativeProductCount.vanillaWarrant != null
            ? derivativesWidget(
                context,
                "⏳",
                "Warrants",
                "🧐 Analysts recommend warrants with 5 DTE.",
                productInfo.derivativeProductCount.vanillaWarrant!,
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            translations.ProductPage.derivativesRiskDisclaimer,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: colors.lessSoftForeground, fontSize: 12),
          ),
        )
      ],
    );
  }
}
