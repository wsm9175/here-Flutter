import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:here/screen/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      home: HomeScreen(),
    )
  );
}

