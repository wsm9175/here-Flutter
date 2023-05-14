import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:here/screen/attendance_screen.dart';
import 'package:here/screen/login_screen.dart';
import 'package:here/screen/register_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
