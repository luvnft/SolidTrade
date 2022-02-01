import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skeletons/skeletons.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/pages/settings_page.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/debug/log.dart';
import 'package:solidtrade/services/util/util.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAppBar extends StatelessWidget with STWidget {
  UserAppBar({Key? key}) : super(key: key);

  final userService = GetIt.instance.get<UserService>();

  void _handleProfileClick() {
    Log.d("Clicked profile.");
  }

  void _handleInviteClick() {
    Log.d("Clicked invite.");
  }

  Widget _getUserProfilePicture(String url, double size) {
    if (!url.endsWith(".svg")) {
      return CachedNetworkImage(
        imageUrl: url,
        height: size,
        width: size,
        placeholder: (context, url) => const SkeletonAvatar(
          style: SkeletonAvatarStyle(shape: BoxShape.circle),
        ),
      );
    }

    return Util.loadSvgImageForWeb(url, size, size);
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
                      side: BorderSide(width: 0.5, color: colors.profilePictureBorder),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: Container(
                        color: colors.background,
                        child: StreamBuilder<RequestResponse<User>?>(
                            stream: userService.stream$,
                            builder: (context, snap) => showLoadingWhileWaiting(
                                  isLoading: !snap.hasData,
                                  loadingBoxShape: BoxShape.circle,
                                  child: _getUserProfilePicture(snap.data?.result?.profilePictureUrl ?? "", 40),
                                )),
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
