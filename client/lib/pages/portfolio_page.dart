import 'package:flutter/foundation.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/historicalposition.dart';
import 'package:solidtrade/pages/settings_page.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/language/en/en_translation.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;
  final AsyncCallback? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack!();
        }
        break;
    }
  }
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final historicalPositionService = GetIt.instance.get<HistoricalPositionService>();

  final configurationProvider = GetIt.instance.get<ConfigurationProvider>();
  ITranslation get translation => configurationProvider.languageProvider.language;
  IColorTheme get colors => configurationProvider.themeProvider.theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RequestResponse<List<HistoricalPosition>>?>(
            stream: historicalPositionService.stream$,
            builder: (context, snap) => Text("The count of historical positions is ${snap.data?.result?.length}"),
          ),
          ElevatedButton(
            onPressed: () {
              historicalPositionService.fetchHistoricalPositions(11003);
            },
            child: const Text("Fetch for update."),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     // Todo: Remove later.
          //     configurationProvider.languageProvider.updateLanguage(EnTranslation());
          //     configurationProvider.themeProvider.updateTheme(ColorThemeType.dark);
          //     // Used to update the ui
          //     setState(() {});
          //   },
          //   child: const Text("(Test) Update language and theme."),
          // )
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage())).then((value) => setState(() {
                    print("hi");
                  }));
            },
            child: const Text("Open settings."),
          )
        ],
      ),
    );
  }
}
