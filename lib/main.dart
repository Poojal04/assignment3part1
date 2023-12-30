import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Album {
  final int id;
  final int userId;
  final String title;

  Album({required this.id, required this.userId, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albums App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AlbumsScreen(),
    );
  }
}

class AlbumsScreen extends StatefulWidget {
  @override
  _AlbumsScreenState createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  List<Album> albums = [];

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  Future<void> fetchAlbums() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Album> fetchedAlbums = body.map((dynamic item) => Album.fromJson(item)).toList();
      setState(() {
        albums = fetchedAlbums;
      });
    } else {
      throw Exception('Failed to load albums');
    }
  }

  Future<void> addAlbum(String title, int userId) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/albums'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'userId': userId,
      }),
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      Album newAlbum = Album.fromJson(responseBody);

      setState(() {
        albums.add(newAlbum); // Add the newly created album to the list
      });
    } else {
      throw Exception('Failed to add album');
    }
  }

  Future<void> deleteAlbum(int albumId) async {
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/albums/$albumId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        albums.removeWhere((album) => album.id == albumId);
      });
    } else {
      throw Exception('Failed to delete album');
    }
  }

  Future<void> _showAddAlbumDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController userIdController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Album'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: userIdController,
                decoration: InputDecoration(labelText: 'User ID'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String title = titleController.text;
                int userId = int.tryParse(userIdController.text) ?? 0;

                if (title.isNotEmpty && userId > 0) {
                  addAlbum(title, userId); // Call addAlbum function with the entered values
                  Navigator.of(context).pop();
                } else {
                  // Show error or validation message if fields are empty or invalid
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
      ),
      body: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return ListTile(
            title: Text(album.title),
            subtitle: Text('ID: ${album.id}, User ID: ${album.userId}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteAlbum(album.id); // Delete album when delete icon is pressed
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAlbumDialog(context); // Show dialog to add a new album
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
