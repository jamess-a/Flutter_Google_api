import 'package:flutter/material.dart';
import 'package:location_api/fav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bottomsheetmenu extends StatefulWidget {
  const Bottomsheetmenu({super.key});

  @override
  State<Bottomsheetmenu> createState() => _BottomsheetmenuState();
}

class _BottomsheetmenuState extends State<Bottomsheetmenu> {
  Set<String> _favorites = Set<String>();
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _favorites = prefs.getStringList('favorites')?.toSet() ?? Set<String>();
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  void _openfavScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavList(favorites: _favorites),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBottomSheetMenu(context, _openfavScreen);
  }
}

Widget _buildBottomSheetMenu(BuildContext context, Function() _openfavScreen) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      
      ListTile(
        leading: Icon(Icons.favorite),
        title: Text('Favorite'),
        onTap: () {
          _openfavScreen();
        },
      ),
    ],
  );
}
