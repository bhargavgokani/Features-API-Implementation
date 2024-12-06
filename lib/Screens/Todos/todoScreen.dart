import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_signup/Screens/Todos/todoInfoScreen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<dynamic> todos = [];
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;
  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse(
          "https://jsonplaceholder.typicode.com/todos?_page=$currentPage&_limit=10");
      final respone = await http.get(url);
      if (respone.statusCode == 200) {
        final List<dynamic> newTodo = json.decode(respone.body);
        setState(() {
          todos.addAll(newTodo);
          currentPage++;
          isLoading = false;
          hasMore = (newTodo.length == 10);
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
          "Todos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F5769),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchTodos();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: todos.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == todos.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final todo = todos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(todo['id'].toString()),
                ),
                subtitle: Text(
                  todo['completed'].toString(),
                  style: TextStyle(
                      fontSize: 14,
                      color: todo['completed'].toString() == 'false'
                          ? Colors.red
                          : Colors.green),
                ),
                title: Text(
                  todo['title'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TodoInfoScreen(
                                title: todo['title'],
                                userId: todo['id'.toString()],
                                completed: todo['completed'],
                              )));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
