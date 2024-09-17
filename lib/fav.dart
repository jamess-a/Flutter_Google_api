import 'package:flutter/material.dart';

class FavList extends StatelessWidget {
  final Set<String> favorites;

  const FavList({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cafes'),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text('No favorites yet.'),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final name = favorites.elementAt(index);
                return ListTile(
                  title: Text(name),
                );
              },
            ),
    );
  }
}
