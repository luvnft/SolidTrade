import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:solidtrade/data/models/common/delete_user_response.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/debug/log.dart';

class UtilUserService {
  static Future<User?> signInWithGoogle({bool signOutFirst = true}) async {
    if (signOutFirst) {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().disconnect();
      await GoogleSignIn().signOut();
    }

    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    Log.w(googleUser?.email);

    if (googleUser == null) {
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    Log.f(FirebaseAuth.instance.currentUser);

    await FirebaseAuth.instance.signInWithCredential(credential);

    return FirebaseAuth.instance.currentUser;
  }

  static Future<RequestResponse<DeleteUserResponse>> deleteAccount(UserService userService) async {
    var response = await userService.deleteUser();

    if (!response.isSuccessful) {
      return response;
    }

    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();
    return response;
  }
}
