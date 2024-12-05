import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'albumDetails.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  List<dynamic> albums = [];
  String searchQuery = '';
  List<dynamic> filteredAlbums = [];
  bool isLoading = true;
  bool isSearch = false;
  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  Future<void> fetchAlbums() async {
    try {
      final response = await http
          .get(Uri.parse("https://jsonplaceholder.typicode.com/albums"));
      if (response.statusCode == 200) {
        setState(() {
          albums = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Faild to load albums');
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

  // void filterAlbums(String query) {
  //   setState(() {
  //     isSearch = true;
  //     searchQuery = query.trim().toLowerCase();
  //     filteredAlbums = albums.where((album) {
  //       final title = album['title'].toLowerCase();
  //       final userId = album['userId'].toString();
  //       return title.contains(searchQuery) || userId == query.trim();
  //     }).toList();
  //   });
  // }

  void filterAlbums(String query) {
    setState(() {
      isSearch = true;
      int? userId = int.tryParse(query);
      if (userId != null) {
        filterByUserId(userId);
      } else {
        filterByTitle(query);
      }
    });
  }

  void filterByTitle(String query) {
    searchQuery = query.toLowerCase();
    filteredAlbums = albums.where((album) {
      final title = album['title'].toLowerCase();
      return title.contains(searchQuery);
    }).toList();
  }

  void filterByUserId(int userId) {
    filteredAlbums = albums.where((album) {
      return album['userId'] == userId; // Match userId exactly
    }).toList();
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
          "Albums",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F5769),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: filterAlbums,
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
                  child: ListView.builder(
                      itemCount:
                          isSearch ? filteredAlbums.length : albums.length,
                      itemBuilder: (context, index) {
                        final album =
                            isSearch ? filteredAlbums[index] : albums[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(album['id'].toString()),
                            ),
                            title: Text(
                              album['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumDetailsScreen(
                                    userId: album['id'],
                                    title: album['title'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                ),
        ],
      ),
    );
  }
}
