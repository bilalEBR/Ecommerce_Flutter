import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientAboutUsPage extends StatelessWidget {
  const ClientAboutUsPage({super.key});

  // Color scheme
  static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
  static const Color accentColor = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EthioMarket',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to EthioMarket, Ethiopia’s premier e-commerce platform dedicated to connecting buyers and sellers across the nation. Founded in 2023, our mission is to empower local businesses, promote Ethiopian-made products, and make online shopping accessible to everyone.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our Vision',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We aim to transform Ethiopia’s digital economy by providing a user-friendly platform that supports micro, small, and medium enterprises (MSMEs) and celebrates the rich diversity of Ethiopian goods, from traditional crafts to modern electronics.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'What We Offer',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• A wide range of products, including fashion, electronics, home appliances, and agricultural goods.\n'
                      '• Support for local sellers to reach a national audience.\n'
                      '• Secure payment options, including mobile money and cash on delivery.\n'
                      '• Affordable delivery with a fixed fee of 150 ETB.\n'
                      '• Group buying features for discounts and community engagement.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Why Choose EthioMarket?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'EthioMarket is more than an online store—it’s a movement to strengthen Ethiopia’s economy and preserve its cultural heritage. By shopping with us, you support local artisans, farmers, and entrepreneurs, contributing to the growth of our vibrant digital marketplace.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}