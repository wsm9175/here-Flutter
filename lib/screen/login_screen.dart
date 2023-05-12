import 'dart:math';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:here/firebase/firebase_login.dart';
import 'package:here/firebase/firebase_realtime_database.dart';
import 'package:here/model/login_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _loginButton('logo_google', login),
                        ),
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('asset/img/logo_google.png'),
                width: 40.0,
                height: 40.0,
              ),
              SizedBox(
                width: 16.0,
              ),
              Text(
                'Google 로그인',
                style: TextStyle(fontSize: 24.0),
              )
            ],
          ),
        ),
      ),
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

  void login() {
    _isLoading.value = true;
    Future<UserCredential> future = firebaseLogin.signInWithGoogle();
    future
        .then((value) => {getUserInfo(value)})
        .catchError((error) => {loginError()});
  }

  void getUserInfo(UserCredential credential) {
    FirebaseRealtimeDatabase firebaseRealtimeDatabase = FirebaseRealtimeDatabase();
    final userData = firebaseRealtimeDatabase.getUserInfo(credential.user!.uid);
    userData
        .then((value) => {
              if (value.exists)
                {settingUserInfo(value)}
              else
                {
                  noUser()
                }
            })
        .catchError((error) => {loginError()});
  }

  void settingUserInfo(DataSnapshot snapshot) {
    LoginUser loginUser = LoginUser();
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    loginUser.settingUserInfo(value, snapshot.key!);
    print(loginUser.toString());
    _isLoading.value = false;
    Navigator.pushNamed(context, '/attendance');
  }

  void loginError() {
    _isLoading.value = false;
  }

  void noUser() async{
   firebaseLogin.signOut();
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
            'HERE',
            style: TextStyle(
              fontSize: 100.0,
              color: Colors.white,
            ),
          ),
          Text(
            '출석 관리 앱',
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
