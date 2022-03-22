import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/st_stream_builder.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/pages/settings_page.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/debug/log.dart';
import 'package:solidtrade/services/util/util.dart';

class UserAppBar extends StatelessWidget with STWidget {
  UserAppBar({Key? key}) : super(key: key);

  final userService = GetIt.instance.get<UserService>();

  void _handleProfileClick() {
    Log.d("Clicked profile.");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.softBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: TextButton(
                  onPressed: _handleProfileClick,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90),
                      side: BorderSide(width: 0.5, color: colors.softBackground),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: Container(
                        color: colors.background,
                        child: STStreamBuilder<User>(
                          stream: userService.stream$,
                          builder: (context, user) => Util.loadImage(
                            user.profilePictureUrl,
                            40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                "Your Portfolio🚀",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: null,
                icon: Icon(Icons.bar_chart_sharp, color: colors.foreground),
                padding: const EdgeInsets.only(right: 10),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.notifications_rounded, color: colors.foreground),
                padding: const EdgeInsets.only(right: 10),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: () => Util.pushToRoute(context, SettingsPage()),
                icon: Icon(Icons.settings_rounded, color: colors.foreground),
                padding: const EdgeInsets.only(right: 12.5),
                constraints: const BoxConstraints(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
