// clientnotifications.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientNotificationsPage extends StatelessWidget {
  const ClientNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Notifications Page - Coming Soon',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}