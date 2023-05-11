import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:here/firebase/firebase_login.dart';
import 'package:here/firebase/firebase_realtime_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
        ),
      ),
    );
  }

  Widget _loginButton(String path, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
                width: 8.0,
              ),
              Text(
                'Google 로그인',
                style: TextStyle(fontSize: 25.0),
              )
            ],
          ),
        ),
      ),
    );
  }

  void login() {
    FirebaseLogin firebaseLogin = FirebaseLogin();
    FirebaseRealtimeDatabase firebaseRealtimeDatabase = FirebaseRealtimeDatabase();
    Future<UserCredential> future =  firebaseLogin.signInWithGoogle();

    future.then((value) => {
      firebaseRealtimeDatabase.getUserInfo(value.user!.uid)
    }).catchError((error) =>{
      print(error)
    });
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
              fontSize: 30.0,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}


class _LoginButton extends StatelessWidget {
  const _LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/attendance');
            },
            child: Text('로그인'),
          ),
        ),
      ],
    );
  }
}
