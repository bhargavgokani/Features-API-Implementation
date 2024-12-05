import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostDetailsScreen extends StatefulWidget {
  final int postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  bool isError = false;
  bool detailsFetched = false;
  bool commentsFetched = false;
  Map<String, dynamic>? postDetails;
  List<dynamic>? postComments;
  bool commentsLoaded = false; // New flag to track if comments have been loaded

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchPostDetails(); // Initially load post details
  }

  Future<void> fetchPostDetails() async {
    if (detailsFetched) return; // Skip if already fetched

    setState(() {
      isLoading = true;
      isError = false;
    });

    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts/${widget.postId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          postDetails = json.decode(response.body);
          isLoading = false;
          detailsFetched = true; // Mark as fetched
        });
      } else {
        throw Exception('Failed to load post details');
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchPostComments() async {
    if (commentsFetched) return; // Skip if already fetched

    setState(() {
      isLoading = true;
      isError = false;
    });

    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts/${widget.postId}/comments');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          postComments = json.decode(response.body);
          isLoading = false;
          commentsFetched = true; // Mark as fetched
        });
      } else {
        throw Exception('Failed to load post comments');
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Widget _buildPostDetails() {
    if (isLoading && !detailsFetched) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isError || postDetails == null) {
      return const Center(
        child: Text(
          'Failed to load post details.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UserId: ${postDetails!['id'].toString()}',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Title:',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            postDetails!['title'],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            'Body:',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            postDetails!['body'],
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget _buildPostComments() {
  //   if (isLoading) {
  //     return const Center(child: CircularProgressIndicator());
  //   }
  //   if (isError || postComments == null) {
  //     return const Center(
  //       child: Text(
  //         'Failed to load post comments.',
  //         style: TextStyle(color: Colors.red),
  //       ),
  //     );
  //   }
  //   return ListView.builder(
  //     itemCount: postComments!.length,
  //     itemBuilder: (context, index) {
  //       final comment = postComments![index];
  //       return Card(
  //         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         child: ListTile(
  //           title: Text(
  //             comment['name'],
  //             style: const TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           subtitle: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(comment['email'],
  //                   style: const TextStyle(color: Colors.grey)),
  //               const SizedBox(height: 4),
  //               Text(comment['body']),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildPostComments() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F5769)),
        ),
      );
    }
    if (isError) {
      return const Center(
        child: Text(
          'Failed to load post comments.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    if (postComments == null) {
      // Display a message indicating no data has been loaded yet
      fetchPostComments();
      isLoading = true;
      return _buildPostComments();
    }
    return ListView.builder(
      itemCount: postComments!.length,
      itemBuilder: (context, index) {
        final comment = postComments![index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              comment['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment['email'],
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  comment['body'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F5769),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Post Details',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey, // Color for unselected tab text
          indicatorColor: Colors.white, // Color of the indicator (underline)

          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              fetchPostDetails();
            } else {
              fetchPostComments();
              commentsLoaded = true; // Set flag to true after first API call
            }
          },
          tabs: const [
            Tab(
                text: 'Details',
                icon: Icon(
                  Icons.details,
                  // color: Colors.white,/
                )),
            Tab(
                text: 'Comments',
                icon: Icon(
                  Icons.comment,
                  // color: Colors.white,
                )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostDetails(),
          _buildPostComments(),
        ],
      ),
    );
  }
}
