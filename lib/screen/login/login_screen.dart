import 'dart:io';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:here/component/device_info_module.dart';
import 'package:here/firebase/firebase_login.dart';
import 'package:here/kakao/kakao_login.dart';
import 'package:here/model/login_user.dart';
import 'package:here/screen/login/login_view_model.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

import '../../firebase/firebase_realtime_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final viewModel = LoginViewModel(KakaoLogin(), FirebaseLogin());
  final FirebaseLogin firebaseLogin = FirebaseLogin();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const _TitleWidget(),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _loginButton('logo_google', login),
                        SizedBox(
                          height: 16.0,
                        ),
                        _appleLoginButton(),
                        SizedBox(
                          height: 16.0,
                        ),
                        _kakaoLoginButton(),
                      ],
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (BuildContext context, bool isLoading, Widget? child) {
                  return isLoading ? _loadingProgress() : SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginButton(String path, VoidCallback onTap) {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.google,
      onPressed: onTap,
    );
  }

  Widget _kakaoLoginButton() {
    return SocialLoginButton(
      backgroundColor: Colors.white,
      text: 'Sign in with Kakao',
      textColor: Colors.black,
      imagePath: 'asset/img/kakao_logo.png',
      onPressed: () async{
        await viewModel.loginKakao(
            settingUserInfo, noUser, nowLoading, noLoading);
      }, buttonType: SocialLoginButtonType.generalLogin,
    );
  }

  Widget _appleLoginButton() {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.apple,
      onPressed: () {
        if (Platform.isAndroid)
          showToast('현재 안드로이드 기기에서 \n애플 로그인은 지원되지 않습니다.');
        else if (Platform.isIOS) appleLogin();
      },
    );
  }

  Widget _loadingProgress() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ],
    );
  }

  void login() async {
    _isLoading.value = true;
    if (FirebaseAuth.instance.currentUser != null)
      await firebaseLogin.signOut();

    Future<UserCredential> future = firebaseLogin.signInWithGoogle();
    future
        .then((value) => {getUserInfo(value)})
        .catchError((error) => {loginError()});
  }

  void appleLogin() async {
    print('apple login');
    _isLoading.value = true;
    if (FirebaseAuth.instance.currentUser != null) await firebaseLogin.signOut();
    Future<UserCredential?> future = firebaseLogin.signInWithApple();
    future
        .then((value) => {getUserInfo(value!)})
        .catchError((error) => {loginError()});
  }

  void getUserInfo(UserCredential credential) {
    FirebaseRealtimeDatabase firebaseRealtimeDatabase =
        FirebaseRealtimeDatabase();
    final userData = firebaseRealtimeDatabase.getUserInfo(credential.user!.uid);
    userData
        .then((value) => {
              if (value.exists) {settingUserInfo(value)} else {noUser()}
            })
        .catchError((error) => {loginError()});
  }

  void settingUserInfo(DataSnapshot snapshot) async {
    LoginUser loginUser = LoginUser();
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    loginUser.settingUserInfo(value, snapshot.key!);
    print(loginUser.toString());
    _isLoading.value = false;
    if (loginUser.deviceUid != await getDeviceUniqueId()) {
      FirebaseLogin().signOut();
      showToast('최초 가입한 기기가 아닙니다. 관리자에게 문의해주세요');
      return;
    }
    Navigator.pushNamed(context, '/attendance');
  }

  void loginError() {
    _isLoading.value = false;
  }

  void noUser() async {
    _isLoading.value = false;
    Navigator.pushNamed(context, '/register');
  }

  nowLoading() {
    _isLoading.value = true;
  }

  noLoading() {
    _isLoading.value = false;
  }
}

class _TitleWidget extends StatelessWidget {
  const _TitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Here',
            style: TextStyle(
              fontSize: 100.0,
              color: Colors.white,
            ),
          ),
          Text(
            '출석 관리를 쉽게',
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
