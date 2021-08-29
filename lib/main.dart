import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ourea/services/authentication/auth_service.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:ourea/services/navigation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initLocator();

//  try {
//    await locator<AuthService>().loginWithEmail(email: 'hack@hack.com', password: 'jackjack');
//  } catch (e) {
//    await locator<AuthService>().signUpWithEmail(email: 'hack@hack.com', password: 'jackjack');
//  }

  await locator<AuthService>().anonymousLogin();
  print('Logged in with uid: ${locator<AuthService>().user.uid}');

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

ThemeData _themeData = ThemeData(
  primaryColor: Colors.deepPurple[500],
  accentColor: Colors.deepPurpleAccent,
  backgroundColor: Colors.deepPurple[900],
  scaffoldBackgroundColor: Colors.deepPurple[900],
);

final FirebaseAnalytics analytics = FirebaseAnalytics();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      title: 'Ourea',
      theme: ThemeData.dark(),
      onGenerateRoute: MyRouter.generateRoute,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
      ],
    );
  }
}
