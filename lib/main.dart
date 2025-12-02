import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/cart_provider.dart';
import 'screens/list_products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDhmSxPftiB9IxIaTsrRTEpboIFv83Pgug",
      authDomain: "avfmonaboer.firebaseapp.com",
      projectId: "avfmonaboer",
      storageBucket: "avfmonaboer.firebasestorage.app",
      messagingSenderId: "615926358346",
      appId: "1:615926358346:web:b9f1e83f1bd6c251a2e1b3"
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boutique Íntima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD32F2F), // Vermelho
          onPrimary: Colors.white,
          secondary: Color(0xFFFF4081), // Rosa
          onSecondary: Colors.white,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Color(0xFFD32F2F),
          centerTitle: true,
          elevation: 0,
        ),
        // Removido CardTheme explícito para evitar conflito de versões, 
        // o card usará as cores do colorScheme.surface automaticamente.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD32F2F)),
          ),
        ),
      ),
      home: const ProductListScreen(),
    );
  }
}