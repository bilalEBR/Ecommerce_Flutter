import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_local/signuppage.dart';
import 'package:ecommerce_local/loginpage.dart';
import 'package:ecommerce_local/adminuser.dart';
import 'package:ecommerce_local/adminseller.dart';
import 'package:ecommerce_local/admincategory.dart';
import 'package:ecommerce_local/adminproduct.dart';
import 'package:ecommerce_local/clienthomepage.dart';
import 'package:ecommerce_local/client-state.dart';
import 'package:ecommerce_local/adminpage.dart';
import 'package:ecommerce_local/sellerhomepage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ClientState())],
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
      initialRoute: '/login',
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/clientpage': (context) => const ClientHomePage(),
        '/adminuser': (context) => const UsersPage(),
        '/adminseller': (context) => const SellerPage(),
        '/admincategory': (context) => const AdminCategoryPage(),
        '/adminproduct': (context) => const ProductsPage(),
        '/admin': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return AdminPage(
            adminId: args?['adminId'] ?? '',
            token: args?['token'] ?? '',
          );
        },
        '/seller': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return SellerHomePage(
            sellerId: args?['sellerId'] ?? '',
            token: args?['token'] ?? '',
          );
        },
      },
    );
  }
}
