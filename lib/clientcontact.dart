import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientContactPage extends StatelessWidget {
   ClientContactPage({super.key});

  // Color scheme
  static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
  static const Color accentColor = Color(0xFFFFD700);

  // Social media links
  final List<Map<String, dynamic>> socialMedia = [
    {
      'name': 'Facebook',
      'icon': Icons.facebook,
      'url': 'https://www.facebook.com/EthioMarket',
      'color': const Color(0xFF3b5998),
    },
    {
      'name': 'Twitter',
      'icon': Icons.alternate_email, // Placeholder, as Twitter icon isn't in Material Icons
      'url': 'https://twitter.com/EthioMarket',

      'color': const Color(0xFF1DA1F2),
    },
    {
      'name': 'Telegram',
      'icon': Icons.send,
     'url': 'https://t.me/Bi456l', 
      'color': const Color(0xFF0088cc),
    },
    {
      'name': 'TikTok',
      'icon': Icons.tiktok_outlined,
      'url': 'https://www.tiktok.com/@ethiomarket',
      'color': const Color(0xFF000000),
    },
    {
      'name': 'YouTube',
      'icon': Icons.play_circle_filled,
      'url': 'https://www.youtube.com/@EthioMarket',
      'color': const Color(0xFFff0000),
    },
  ];

  // Function to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error (e.g., show SnackBar)
      // Note: ScaffoldMessenger requires context, so this is handled in build
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Contact',
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
              'Get in Touch',
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
                      'Connect with us on social media:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      alignment: WrapAlignment.center,
                      children: socialMedia.map((platform) {
                        return GestureDetector(
                          onTap: () async {
                            try {
                              await _launchUrl(platform['url']);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not launch ${platform['name']}: $e')),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: platform['color'],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  platform['icon'],
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                platform['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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