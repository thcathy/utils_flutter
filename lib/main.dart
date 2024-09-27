import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:utils_flutter/views/home_page.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';

Future<void> main() async {
  const String env = String.fromEnvironment('ENV', defaultValue: 'prod');
  await dotenv.load(fileName: 'env.$env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'THC Utils',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, primary: Colors.blue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          shadowColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white), // Icon color in AppBar
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Title text style
        ),
        // You can customize more colors here
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue, // Button background color
          textTheme: ButtonTextTheme.primary, // Button text color
        ),
        useMaterial3: true
      ),
      home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
                Auth0Web('thcathy.auth0.com', 'mBv3zeOBD6Wl2NI2zMzeJFO8kZU7XyJl'),
                Auth0('thcathy.auth0.com', 'mBv3zeOBD6Wl2NI2zMzeJFO8kZU7XyJl'),
              )..add(AuthEventInit()),
          child: const HomePage()
      ),
    );
  }
}
