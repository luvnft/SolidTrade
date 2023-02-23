import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solidtrade/providers/localization.provider.dart';
import 'package:solidtrade/utils/translations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Text(
          Translations.of(context).helloWorld,
        ),
      ),
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            onPressed: () {
              ref.read(localizationProvider.notifier).changeLanguageToEnglish();
            },
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              ref.read(localizationProvider.notifier).changeLanguageToGerman();
            },
            child: const Icon(Icons.ice_skating),
          )
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:solidtrade/screens/home/widgets/user_app_bar.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedTabIndex = 0;

//   static final List<Widget> _widgets = <Widget>[
//     const PortfolioPage(),
//     // const SearchPage(),
//     const Text('data'),
//     const Text('data'),
//     const Text('data'),
//   ];

//   void _handleItemIndexClick(int index) {
//     setState(() {
//       _selectedTabIndex = index;
//     });
//   }

//   Color _getItemColor(int itemIndex) {
//     return Colors.grey;
//     // return itemIndex == _selectedTabIndex ? colors.selectedItem : colors.unselectedItem;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           const UserAppBar(),
//           // Expanded(
//           //   child: LayoutBuilder(
//           //     builder: (context, constraints) => SizedBox(
//           //       height: constraints.maxHeight,
//           //       child: _widgets[_selectedTabIndex],
//           //     ),
//           //   ),
//           // )
//           Expanded(
//             child: _widgets[_selectedTabIndex],
//           )
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(label: translations.navigationBar.portfolio, icon: Icon(Icons.insights, color: _getItemColor(0))),
//           BottomNavigationBarItem(label: translations.navigationBar.search, icon: Icon(Icons.search, color: _getItemColor(1))),
//           BottomNavigationBarItem(label: translations.navigationBar.leaderboard, icon: Icon(Icons.leaderboard, color: _getItemColor(2))),
//           BottomNavigationBarItem(label: translations.navigationBar.profile, icon: Icon(Icons.person, color: _getItemColor(3))),
//         ],
//         backgroundColor: colors.navigationBackground,
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         currentIndex: _selectedTabIndex,
//         onTap: _handleItemIndexClick,
//       ),
//     );
//   }
// }
