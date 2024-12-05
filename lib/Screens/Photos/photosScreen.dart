import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotosScreen extends StatefulWidget {
  @override
  _PhotosScreenState createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  List<dynamic> photos = [];
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 50;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://jsonplaceholder.typicode.com/photos?_page=$currentPage&_limit=$pageSize'),
      );

      if (response.statusCode == 200) {
        List<dynamic> newPhotos = json.decode(response.body);
        setState(() {
          photos.addAll(newPhotos);
          currentPage++;
          isLoading = false;
          hasMore = newPhotos.length == pageSize;
        });
      } else {
        throw Exception('Failed to load photos');
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

  void showImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(imageUrl),
      ),
    );
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
          'Photo List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF3F5769),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchPhotos();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: photos.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == photos.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final photo = photos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => showImage(photo['url']),
                  child: ClipOval(
                    child: Image.network(
                      photo['thumbnailUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                subtitle: Text(
                  photo['title'],
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                title: Text(
                  "ID: ${photo['id']}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
