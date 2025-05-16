import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientFAQsPage extends StatelessWidget {
  const ClientFAQsPage({super.key});

  // Color scheme
  static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
  static const Color accentColor = Color(0xFFFFD700);

  // FAQ data
  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is EthioMarket app?',
      'answer':
          'EthioMarket is a leading e-commerce platform in Ethiopia, designed to connect buyers and sellers across the country. It offers a wide range of products, including electronics, fashion, home appliances, and agricultural goods, with a focus on promoting local businesses and Ethiopian-made products.'
    },
    {
      'question': 'What can I do with EthioMarket?',
      'answer':
          'With EthioMarket, you can browse and purchase a variety of products, sell your own goods as a vendor, manage your orders, track deliveries, and engage in group buying for discounts. The app also supports secure payments and provides a user-friendly interface for seamless shopping.'
    },
    {
      'question': 'Who is eligible to use EthioMarket?',
      'answer':
          'Anyone in Ethiopia with a smartphone and internet access can use EthioMarket. Buyers and sellers must be at least 18 years old and comply with our terms of service. No special qualifications are required to start shopping or selling.'
    },
    {
      'question': 'How do I sign up/register for EthioMarket?',
      'answer':
          'To sign up, download the EthioMarket app from the Google Play Store or Apple App Store, or visit our website. Click "Register," provide your name, email, phone number, and a password, then verify your account via email or SMS. Registration is quick and free.'
    },
    {
      'question': 'Do I need to pay while registering for EthioMarket?',
      'answer':
          'No, registering for EthioMarket is completely free for both buyers and sellers. You only pay for products you purchase or a 5% commission per product if you sell on the platform.'
    },
    {
      'question': 'How can I buy products in EthioMarket?',
      'answer':
          'Browse products on the app or website, add items to your cart, and proceed to checkout. Enter your shipping address, choose a payment method (e.g., mobile money, bank card, or cash on delivery), and confirm your order. You’ll receive delivery updates.'
    },
    {
      'question': 'How can I reset my EthioMarket password?',
      'answer':
          'On the login page, click "Forgot Password." Enter your registered email or phone number, and follow the instructions to receive a password reset link or code. Use it to set a new password and regain access to your account.'
    },
    {
      'question': 'How much do I pay for using EthioMarket as a seller?',
      'answer':
          'Sellers pay a 5% commission on each product sold through EthioMarket. There are no additional fees for listing products or maintaining a seller account.'
    },
    {
      'question': 'How much do I pay for delivery of products?',
      'answer':
          'Delivery costs a fixed fee of 150 ETB per order, regardless of the number of items or distance within Ethiopia. This fee is added at checkout.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'FAQs',
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
            // Text(
            //   'Frequently Asked Questions',
            //   style: GoogleFonts.poppins(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: primaryColor,
            //   ),
            // ),
            const SizedBox(height: 15),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: faqs.map((faq) {
                    return ExpansionTile(
                      leading: Icon(Icons.question_answer, color: primaryColor),
                      title: Text(
                        faq['question']!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            faq['answer']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}