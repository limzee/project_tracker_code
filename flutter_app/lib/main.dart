import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_tracker/map_screen.dart';
import 'add_unit_screen.dart';
import 'add_unit_screen2.dart';
import 'add_unit_screen3.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          final isLoggedIn = snapshot.hasData;
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: isLoggedIn ? '/' : '/login',
            routes: {
              '/': (context) => const MapScreen(),
              '/add_unit': (context) => const AddUnitScreen(),
              '/add_unit_2': (context) => const AddUnitScreen2(),
              '/login': (context) => const LoginScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/add_unit_3') {
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (context) => AddUnitScreen3(
                    userId: args['userId']!,
                    unitId: args['unitId']!,
                  ),
                );
              }
            },
          );
        }
      }
    );
  }
}