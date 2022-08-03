import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'database/user.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/phone_screens/phone_main_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/web_screens/web_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  Directory appDocumentDirectory;

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  }

  Hive.registerAdapter(UserAdapter());

  await Hive.openBox("user");

  runApp(
    MaterialApp(
      home: const MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hive.box("user").isEmpty
        ? const LoginScreen()
        : const ResponsiveLayout(
            phoneBody: PhoneMainScreen(),
            webBody: WebMainScreen(),
          );
  }
}
