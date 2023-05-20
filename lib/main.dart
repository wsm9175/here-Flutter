import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:here/screen/attendance_screen.dart';
import 'package:here/screen/login/login_screen.dart';
import 'package:here/screen/register_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  KakaoSdk.init(nativeAppKey: '2ac526f273bf0503b498be5a39204865');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginScreen(),
      '/attendance': (context) => AttendanceScreen(),
      '/register' : (context) => RegisterScreen(),
    },
  ));
}
