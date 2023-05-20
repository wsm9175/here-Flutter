import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:here/firebase/firebase_auth_remote_data_source.dart';
import 'package:here/firebase/firebase_login.dart';
import 'package:here/firebase/firebase_realtime_database.dart';
import 'package:here/kakao/kakao_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import '../../model/login_user.dart';

class LoginViewModel{
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();
  final KakaoLogin _kakaoLogin;
  final FirebaseLogin _firebaseLogin;
  bool isLogined = false;
  kakao.User? user;

  LoginViewModel(this._kakaoLogin, this._firebaseLogin);

  Future loginKakao(Function(DataSnapshot) settingUserInfo, Function() noUser, Function() nowLoading, Function() noLoading) async{
    nowLoading();
    isLogined = await _kakaoLogin.login();
    if(isLogined){
      user = await kakao.UserApi.instance.me();

      final customToken = await _firebaseAuthDataSource.createCustomToken({
        'uid' : user!.id.toString(),
        'displayName' : user!.kakaoAccount!.profile!.nickname,
        'email' : user!.kakaoAccount!.email!,
      });

      await FirebaseAuth.instance.signInWithCustomToken(customToken);
      await getUserInfoKakao(settingUserInfo, noUser);
    }
    noLoading();
  }

  Future logoutKakao() async {
    await _kakaoLogin.logout();
    await _firebaseLogin.signOut();
    isLogined = false;
    user = null;
  }

  Future getUserInfoKakao(Function(DataSnapshot) settingUserInfo, Function() noUser) async{
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final userData = await FirebaseRealtimeDatabase().getUserInfo(uid);
    if(userData.exists) {
      settingUserInfo(userData);
    }else{
      noUser();
    }
  }
}