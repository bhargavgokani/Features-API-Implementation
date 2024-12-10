import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/Screens/Todos/todoScreen.dart';
import 'package:login_signup/Screens/aboutScreen.dart';
import 'package:login_signup/Screens/Album/albums.dart';
import 'package:login_signup/Screens/Post/posts.dart';
import 'package:login_signup/Screens/Photos/photosScreen.dart';
import 'package:login_signup/Screens/settingScreen.dart';
import 'package:login_signup/Screens/PostList/postListScreen.dart';

import 'Map/MapScreen.dart';
import 'MapList/MapListScreen.dart';
import 'Profile/profileScreen.dart';

class Homescreeen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;
  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Home screen"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width *
            0.75, // Set width to half the screen
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF3F5769),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Post'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PostsScreen())); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Album'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AlbumsScreen())); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Posts List'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PostListScreen())); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_sharp),
              title: const Text('Photos'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PhotosScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Todo'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TodoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Map'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_location_sharp),
              title: const Text('MapList'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Maplistscreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Users'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen())); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const Settingscreen())); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Aboutscreen())); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Color(0xFF3F5769)),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            signout();
                            Navigator.pop(context); // Close the dialog
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Color(0xFF3F5769)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(
          child: Text(
            "Hello, ${user?.email}",
          ),
        ),
        ElevatedButton(
          onPressed: (() => signout()),
          style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(const Color(0xFF3F5769))),
          child: const Text(
            "sign out",
            style: TextStyle(color: Colors.white),
          ),
        )
      ]),
    );
  }
}
