import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/services/util/util.dart';

class UserAppBar extends StatelessWidget with STWidget {
  UserAppBar({Key? key}) : super(key: key);

  late DateTime now;

  // TODO: Remove me in the future.
  var url = "https://res.cloudinary.com/rosemite/image/upload/v1642702565/Projects/SolidTrade-Development/8AcxJgUEZvUWuN9JnfxNSwLahCb2_gypoxj.svg";

  void _handleProfileClick() {
    print("Clicked profile.");
  }

  void _handleInviteClick() {
    print("Clicked invite.");
  }

  Widget _getUserProfilePicture(String url, double size) {
    if (!url.endsWith(".svg")) {
      return Image.network(
        url,
        height: size,
        width: size,
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
                  child: _getUserProfilePicture(
                    url,
                    60,
                  ),
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
                  Text("Invite", style: TextStyle(color: colors.darkGreen)),
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
