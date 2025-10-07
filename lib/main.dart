import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgarage/auth/Secreen/HomePage.dart';

import 'package:smartgarage/auth/Secreen/authgard.dart';
import 'package:smartgarage/auth/Secreen/login.dart';
import 'package:smartgarage/screens/add_brand_screen.dart';
import 'package:smartgarage/screens/brands_list_screen.dart';
import 'package:smartgarage/screens/cateegory/CategoryListScreen.dart';
import 'package:smartgarage/screens/parts_list_screen.dart';

import 'package:smartgarage/screens/motos/moto_list_screen.dart';
import 'package:smartgarage/screens/motos/add_moto_screen.dart';
import 'package:smartgarage/screens/purchase/add_purchase_screen.dart';
import 'package:smartgarage/screens/purchase/cleint/ClientCartScreen.dart';
import 'package:smartgarage/screens/purchase/cleint/ClientsListScreen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Optional: Use local emulators for development
  if (kDebugMode) {
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );

    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  runApp( ProviderScope(
      child:  StockApp()));
}

class StockApp extends StatelessWidget {
  const StockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Garage Manager',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      initialRoute: '/',
      routes: {
        // 🧩 Auth routes
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
   '/category': (context) => const CategoryListScreen(isAdmin: true),
        // 🧰 Parts routes
        '/parts': (context) => const PartsListScreen(isAdmin: true),
        '/purchases/add': (context) => const AddPurchaseScreen(),
        '/cleint': (context) => ClientsListScreen(),
        //'/cleint/detail': (context) => ClientCartScreen(),
        // 🏍️ Motos routes
        '/motos': (context) => const MotoListScreen(isAdmin: true),
        '/motos/add': (context) => const AddMotoScreen(),

        // 🏷️ Brands routes
        '/brands': (context) => const BrandsListScreen(),
        '/brands/add': (context) => const AddBrandScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      },
    );
  }
}
