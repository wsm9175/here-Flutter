import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:here/model/login_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseLogin{
  User? user;
  String? email;
  String? fulName;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print(appleCredential);

      try{
        email = appleCredential.email;
        fulName = appleCredential.familyName! + appleCredential.givenName!;
      }catch(error){
        print(error);
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );


      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch(error) {
      print(error);
      return null;
    }
  }


  Future<void> signOut() async{
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    LoginUser().logout();
  }

  Future<void> revoke() async{
    FirebaseAuth.instance.currentUser?.delete();
    LoginUser().logout();
  }

}

