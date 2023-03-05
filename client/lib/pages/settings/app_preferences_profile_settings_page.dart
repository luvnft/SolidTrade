import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_page.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/dtos/user/request/update_user_dto.dart';
import 'package:solidtrade/services/util/util.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key, required this.updateUserDto}) : super(key: key);
  final UpdateUserDto updateUserDto;

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> with STWidget {
  late bool _hasPublicPortfolio;
  late UpdateUserDto _userDto;

  // Controllers
  final _bioController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();

  bool get _hasUpdatedProfile => _userDto.hasUpdatedProfileByDto(widget.updateUserDto);

  @override
  void initState() {
    super.initState();

    _userDto = UpdateUserDto.copyWith(widget.updateUserDto);

    _hasPublicPortfolio = _userDto.publicPortfolio;

    _bioController.text = _userDto.bio;
    _displayNameController.text = _userDto.displayName;
    _emailController.text = _userDto.email;
    _usernameController.text = _userDto.username;
  }

  void _bioChanged(String bio) => _userDto.bio = bio;
  void _emailChanged(String email) => _userDto.email = email;
  void _displayNameChanged(String displayName) => _userDto.displayName = displayName;
  void _usernameChanged(String username) => _userDto.username = username;
  void _hasPublicPortfolioChanged(bool hasPublicPortfolio) {
    _userDto.publicPortfolio = hasPublicPortfolio;

    setState(() {
      _hasPublicPortfolio = hasPublicPortfolio;
    });
  }

  // TODO: Maybe use the same text inputs, used in the sign up process, in the future...
  // TextFormField(
  //     controller: _nameController,
  //     cursorColor: colors.foreground,
  //     decoration: getInputDecoration("Name"),
  //   ),

  Widget _inputField({
    required String title,
    required TextEditingController controller,
    required Function(String) callback,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      width: double.infinity,
      height: maxLines == 1 ? 90 : 200,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10),
          TextFormField(
            maxLines: maxLines,
            onChanged: (content) => callback(content),
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hintText,
              labelText: title,
            ),
          ),
        ],
      ),
    );
  }

  void _handleClickDiscard() async {
    if (!_hasUpdatedProfile || await Util.showUnsavedChangesWarningDialog(context)) {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return STPage(
      page: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close, size: 25, color: Colors.red[300]),
            onPressed: _handleClickDiscard,
          ),
          title: const Text("Customize your Profile"),
          elevation: 5,
          centerTitle: true,
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done, size: 25, color: Colors.blue[300]),
              onPressed: () => Navigator.of(context).pop(_userDto),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15),
              // Text(
              //   "Customize your Profile",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     color: alertColor,
              //     fontSize: 22.5,
              //   ),
              // ),
              const SizedBox(height: 15),
              _inputField(title: 'Bio', controller: _bioController, callback: (content) => _bioChanged(content), maxLines: 5, hintText: _bioController.text),
              _inputField(title: 'Email', controller: _emailController, callback: (content) => _emailChanged(content), hintText: _emailController.text),
              _inputField(title: 'Name', controller: _displayNameController, callback: (content) => _displayNameChanged(content), hintText: _displayNameController.text),
              _inputField(title: 'Username', controller: _usernameController, callback: (content) => _usernameChanged(content), hintText: '@' + _usernameController.text),
              SwitchListTile(title: const Text("Public portfolio"), value: _hasPublicPortfolio, onChanged: _hasPublicPortfolioChanged),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
