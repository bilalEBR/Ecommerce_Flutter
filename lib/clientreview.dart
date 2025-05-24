import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'client-state.dart';
import 'baseurl.dart';

class ReviewPage extends StatefulWidget {
  final String productId;
  final int? userRating;

  const ReviewPage({super.key, required this.productId, this.userRating});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Map<String, dynamic>> reviews = [];
  int totalReviews = 0;
  bool isLoading = true;
  String? errorMessage;
  int skip = 0;
  final int limit = 10;
  bool hasMore = true;
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool canReview = false;
  Map<String, dynamic>? userReview;

  @override
  void initState() {
    super.initState();
    if (widget.userRating != null) {
      _rating = widget.userRating!;
    }
    _fetchReviews();
    _checkCanReview();
  }

  Future<void> _fetchReviews({bool loadMore = false}) async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;

    if (token == null || token.isEmpty) {
      print('Token is null or empty, redirecting to login');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (loadMore) {
      setState(() {
        skip += limit;
      });
    } else {
      setState(() {
        skip = 0;
        reviews = [];
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/client-products/reviews/${widget.productId}?limit=$limit&skip=$skip',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        'Fetch reviews response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reviews.addAll(data['reviews'].cast<Map<String, dynamic>>());
          totalReviews = data['totalReviews'];
          isLoading = false;
          hasMore = data['reviews'].length == limit;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print(
          'Authentication error (${response.statusCode}), redirecting to login',
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          errorMessage = 'Failed to fetch reviews: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        errorMessage = 'Error fetching reviews: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _checkCanReview() async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final userId = clientState.userId;
    final token = clientState.token;

    if (userId == null || token == null) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/orders/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final orders = jsonDecode(response.body);
        final hasPurchased = orders.any(
          (order) =>
              order['status'] == 'completed' &&
              order['items'].any(
                (item) => item['productId'] == widget.productId,
              ),
        );
        setState(() {
          canReview = hasPurchased;
        });
      }

      // Check for existing review
      final reviewResponse = await http.get(
        Uri.parse('$baseUrl/client-products/reviews/${widget.productId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (reviewResponse.statusCode == 200) {
        final data = jsonDecode(reviewResponse.body);
        final userRev = data['reviews'].firstWhere(
          (review) => review['userId'] == userId,
          orElse: () => null,
        );
        if (userRev != null) {
          setState(() {
            userReview = userRev;
            _rating = userRev['rating'];
            _commentController.text = userRev['comment'];
          });
        }
      }
    } catch (e) {
      print('Error checking review eligibility: $e');
    }
  }

  Future<void> _submitOrUpdateReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;
    final userId = clientState.userId;

    if (token == null || userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final url =
          userReview == null
              ? '$baseUrl/client-products/reviews/${widget.productId}'
              : '$baseUrl/client-products/reviews/${userReview!['_id']}';
      final method = userReview == null ? http.post : http.put;

      final response = await method(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': _rating,
          'comment': _commentController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userReview == null
                  ? 'Review submitted successfully'
                  : 'Review updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _commentController.clear();
        setState(() {
          _rating = 0;
          userReview = null;
        });
        _fetchReviews();
        _checkCanReview();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${userReview == null ? 'submit' : 'update'} review: ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error ${userReview == null ? 'submitting' : 'updating'} review: $e',
          ),
        ),
      );
    }
  }

  Future<void> _deleteReview() async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;
    final userId = clientState.userId;

    if (token == null || userId == null || userReview == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/client-products/reviews/${userReview!['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _commentController.clear();
        setState(() {
          _rating = 0;
          userReview = null;
        });
        _fetchReviews();
        _checkCanReview();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete review: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting review: $e')));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reviews', style: GoogleFonts.poppins())),
      body:
          isLoading && reviews.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!, style: GoogleFonts.poppins()))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews ($totalReviews)',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (canReview && userReview == null ||
                        userReview != null) ...[
                      Text(
                        userReview == null
                            ? 'Write a Review'
                            : 'Edit Your Review',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Your Review',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _submitOrUpdateReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              userReview == null
                                  ? 'Submit Review'
                                  : 'Update Review',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                          if (userReview != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _deleteReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Delete Review',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (reviews.isEmpty)
                      Text(
                        'No reviews yet.',
                        style: GoogleFonts.poppins(fontSize: 14),
                      )
                    else
                      ...reviews.map(
                        (review) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    review['profileImage'] != null
                                        ? NetworkImage(
                                          '$baseUrl${review['profileImage']}',
                                        )
                                        : null,
                                child:
                                    review['profileImage'] == null
                                        ? const Icon(Icons.person, size: 25)
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['username'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      review['comment'] ?? '',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < review['rating']
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(
                                        DateTime.parse(review['updatedAt']),
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasMore)
                      TextButton(
                        onPressed: () => _fetchReviews(loadMore: true),
                        child: Text(
                          'Load More',
                          style: GoogleFonts.poppins(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
