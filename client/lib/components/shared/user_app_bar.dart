import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skeletons/skeletons.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/user.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            child: _getUserProfilePicture(snap.data?.result?.profilePictureUrl ?? "", 60),
                          )),
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: _handleInviteClick,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0)),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45),
              side: BorderSide(width: 1, color: colors.midGreen),
            ),
            elevation: 0,
            color: colors.lightGreen,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.person_add_outlined, color: colors.darkGreen),
                  const SizedBox(width: 10),
                  Text(translations.userAppBar.invite, style: TextStyle(color: colors.darkGreen)),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
