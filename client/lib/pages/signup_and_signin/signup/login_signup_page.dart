import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/pages/settings/crop_image_page.dart';
import 'package:solidtrade/pages/signup_and_signin/components/login_screen.dart';
import 'package:solidtrade/pages/signup_and_signin/signup/continue_signup_page.dart';
import 'package:solidtrade/services/util/util.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({required this.email, Key? key}) : super(key: key);
  final String email;

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> with STWidget {
  Uint8List? imageAsBytes;
  bool showSeedInputField = true;

  String _dicebearSeed = 'your-custom-seed';
  late String _tempCurrentSeed;

  Future<void> _handleChangeSeed(String seed) async {
    if (seed.length > 100) {
      return;
    }

    _tempCurrentSeed = seed;

    await Future.delayed(const Duration(milliseconds: 400));

    if (_tempCurrentSeed != seed) {
      return;
    }

    setState(() {
      _dicebearSeed = seed;
    });
  }

  Future<void> _handleClickUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (await image.length() > Constants.fileUploadLimitInBytes) {
      Util.openDialog(context, 'File too large', message: 'Sorry, this image is too big.');
      return;
    }

    var isGifFile = image.name.endsWith('.gif');

    if (kIsWeb) {
      var bytes = await image.readAsBytes();

      if (!isGifFile) {
        final closeDialog = Util.showLoadingDialog(context, showIndicator: false, waitingText: 'Loading. This might take a while...');

        await Future.delayed(const Duration(milliseconds: 400));

        var cropResult = await Navigator.push<Future<Uint8List>?>(
          context,
          MaterialPageRoute(
            builder: (ctx) => Cropper(
              image: bytes,
            ),
          ),
        );

        closeDialog();

        if (cropResult == null) {
          return;
        }

        var croppedImageResult = await cropResult;

        setState(() {
          showSeedInputField = false;
          imageAsBytes = croppedImageResult;
        });

        return;
      }

      setState(() {
        showSeedInputField = false;
        imageAsBytes = bytes;
      });
      return;
    }

    File? cropped;

    // For gif's cropping can not be applied
    if (!isGifFile) {
      var croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        aspectRatioPresets: [
          CropAspectRatioPreset.square
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
          )
        ],
      );

      if (croppedFile == null) return;

      cropped = File(croppedFile.path);
    } else {
      cropped = File(image.path);
    }

    setState(() {
      showSeedInputField = false;
      imageAsBytes = cropped!.readAsBytesSync();
    });
  }

  Future<void> _handleClickContinueSignUp() async {
    Util.pushToRoute(
        context,
        ContinueSignupScreen(
          email: widget.email,
          dicebearSeed: _dicebearSeed,
          profilePictureBytes: imageAsBytes,
        ));
  }

  List<Widget> _roundedButtons(bool showButtons) {
    if (!showButtons) {
      return [];
    }

    return [
      Util.roundedButton(
        [
          const SizedBox(width: 2),
          const Text(
            'Upload own picture. GIFs are also supported!',
          ),
          const SizedBox(width: 2),
        ],
        colors: colors,
        onPressed: _handleClickUploadImage,
      ),
      const SizedBox(height: 10),
      Util.roundedButton(
        [
          const Spacer(flex: 8),
          SizedBox(width: IconTheme.of(context).size),
          const Text('Looks good? Continue here'),
          const Spacer(flex: 7),
          const Icon(Icons.keyboard_arrow_right_rounded),
          const Spacer(flex: 1),
        ],
        colors: colors,
        onPressed: _handleClickContinueSignUp,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (_, isKeyboardVisible) => LoginScreen(
        imageUrl: 'https://avatars.dicebear.com/api/micah/$_dicebearSeed.svg',
        imageAsBytes: imageAsBytes,
        title: 'Welcome to Solidtrade!',
        subTitle: "Ready to create your solidtrade profile? Let's start with your profile picture!\nType a custom seed to generate a picture or upload your own custom image.",
        alternativeTitle: 'Type a custom seed to generate a picture!',
        useAlternativeTitleContent: isKeyboardVisible,
        additionalWidgets: [
          showSeedInputField
              ? SizedBox(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                      hintText: 'Why not enter your name 😉',
                    ),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    initialValue: _dicebearSeed,
                    onChanged: _handleChangeSeed,
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 10),
          ..._roundedButtons(!isKeyboardVisible),
        ],
      ),
    );
  }
}
