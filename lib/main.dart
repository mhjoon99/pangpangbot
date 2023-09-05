import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'loading.dart';
import 'firebase_options.dart';
import 'model_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Loading(),
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Authentication(),
    );
  }
}

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return SignInScreen(
              headerBuilder: (context, constraints, double){
                return Padding(padding: EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                  ),
                );
              },
              providerConfigs: [
                EmailProviderConfiguration()
              ],
            );
          }
          return ModelScreen();
        },
    );
  }
}
