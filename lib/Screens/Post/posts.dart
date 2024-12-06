import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_signup/Screens/Post/postDetails.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  bool isSearch = false;
  String searchQuery = '';
  List<dynamic> filteredAlbums = [];

  void filterPosts(String query) {
    setState(() {
      isSearch = true;
      searchQuery = query.trim().toLowerCase();
      filteredAlbums = posts.where((post) {
        final title = post['title'].toLowerCase();
        final subtitle = post['body'].toLowerCase();
        final userId = post['userId'].toString();
        return title.contains(searchQuery) ||
            userId == query.trim() ||
            subtitle.contains(searchQuery);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http
          .get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          "Posts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F5769),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: filterPosts,
              decoration: InputDecoration(
                labelText: 'Search by User ID or Title',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchPosts, // Pull-to-refresh API call
                    child: ListView.builder(
                      itemCount:
                          isSearch ? filteredAlbums.length : posts.length,
                      itemBuilder: (context, index) {
                        final post =
                            isSearch ? filteredAlbums[index] : posts[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(post['id'].toString()),
                            ),
                            title: Text(
                              post['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis to truncate text
                              maxLines: 1, // Restrict to a single line
                            ),
                            subtitle: Text(
                              post['body'],
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis to truncate text
                              maxLines: 2, // Restrict to a single line
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailsScreen(
                                    postId: post['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
