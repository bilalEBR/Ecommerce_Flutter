// clientprofile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Page - Coming ytyt Soon',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}