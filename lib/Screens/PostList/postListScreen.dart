import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_signup/Screens/PostList/postListInfo.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  bool isLoading = true;
  bool isLoadingMore = false; // For showing loader during pagination
  int page = 1;
  int nextpage = 1;
  List<dynamic> posts = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    fetchPostList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPostList({bool isPagination = false}) async {
    if (isPagination) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final uri = Uri.parse(
          "https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=10");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> newPosts = json.decode(response.body);
        setState(() {
          if (isPagination) {
            posts.addAll(newPosts); // Append new data to the list
            isLoadingMore = false;
          } else {
            posts = newPosts;
            isLoading = false;
          }
          nextpage++;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        (page + 1 == nextpage)) {
      // If at the bottom of the scroll, load the next page
      page++;
      fetchPostList(isPagination: true);
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
          "Post Lists",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F5769),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF3F5769)),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // Attach scroll controller
                    itemCount: posts.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        // Show loader at the end of the list
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final post = posts[index];
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
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis to truncate text
                            maxLines: 1, // Restrict to a single line
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostListInfo(
                                  userId: post['id'],
                                  title: post['title'],
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            Fluttertoast.showToast(
                              msg: "Card ID: ${post['id']}",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Color(0xFF3F5769),
                              // textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
