import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; 
import 'firebase_options.dart';
import 'package:targetku/screens/onboarding_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // <-- 2. TAMBAHKAN BLOK KODE INI
  // Aktifkan App Check dalam mode debug untuk Android
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MyApp());
}

// ... sisa kode MyApp Anda tetap sama ...
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TargetKu',
      theme: ThemeData(
        primarySwatch:  MaterialColor(0xFFF6C634, 
        <int, Color>
        {
          50: Color(0xFFFFF8E1),
          100: Color(0xFFFFECB3),
          200: Color(0xFFFFE082),
          300: Color(0xFFFFD54F),
          400: Color(0xFFFFCA28),
          500: Color(0xFFF6C634), 
          600: Color(0xFFFFB300),
          700: Color(0xFFFFA000),
          800: Color(0xFFFF8F00),
          900: Color(0xFFFF6F00),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardingScreen(),
    );
  }
}