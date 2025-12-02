import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/list_products.dart';
import 'package:firebase_core/firebase_core.dart';

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
      title: 'Loja de Joias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}