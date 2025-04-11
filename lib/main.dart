
// // main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:ecommerce_local/signuppage.dart';
// import 'package:ecommerce_local/loginpage.dart';
// import 'package:ecommerce_local/adminpage.dart';
// import 'package:ecommerce_local/adminuser.dart';
// import 'package:ecommerce_local/admincategory.dart';
// import 'package:ecommerce_local/adminproduct.dart';
// import 'package:ecommerce_local/clienthomepage.dart';
// import 'package:ecommerce_local/client-state.dart'; // Import the ClientState provider
// // Note: We don't need to import sellerhomepage.dart here anymore

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ClientState()), // Add ClientState provider
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Local ecommerce app',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       initialRoute: '/signup',
//       routes: {
//         '/signup': (context) => const SignupPage(),
//         '/login': (context) => const LoginPage(),
//         '/clientpage': (context) => const ClientHomePage(),
//         '/adminpage': (context) => const AdminPage(),
//         '/adminuser': (context) => const UsersPage(),
//         '/admincategory': (context) => const AdminCategoryPage(),
//         '/adminproduct': (context) => const AdminProductPage(),
//       },
//     );
//   }
// }



// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_local/signuppage.dart';
import 'package:ecommerce_local/loginpage.dart';
import 'package:ecommerce_local/adminuser.dart';
import 'package:ecommerce_local/adminseller.dart';
import 'package:ecommerce_local/admincategory.dart';
import 'package:ecommerce_local/adminproduct.dart';
import 'package:ecommerce_local/clienthomepage.dart';
import 'package:ecommerce_local/client-state.dart'; // Import the ClientState provider

// Note: We don't need to import sellerhomepage.dart here anymore
// Removed import for adminpage.dart since we navigate programmatically

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientState()), // Add ClientState provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local ecommerce app',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/clientpage': (context) => const ClientHomePage(),
        '/adminuser': (context) => const UsersPage(),
        '/adminseller': (context) => const SellerPage(),
        '/admincategory': (context) => const AdminCategoryPage(),
        '/adminproduct': (context) => const ProductsPage(),
      },
    );
  }
}