import 'package:flutter/material.dart';
import 'package:location_api/fav_cafe.dart';
import 'package:location_api/fav_res.dart';
import 'package:location_api/fav_shop.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Bottomsheetmenu extends StatefulWidget {
  const Bottomsheetmenu({super.key});

  @override
  State<Bottomsheetmenu> createState() => _BottomsheetmenuState();
}

class _BottomsheetmenuState extends State<Bottomsheetmenu> {
  Set<String> _favorites = Set<String>();
  Set<String> _loadFavorites_restaurant = Set<String>();
  Set<String> _loadFavorites_shops = Set<String>();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _favorites = prefs.getStringList('favorites')?.toSet() ?? Set<String>();
        _loadFavorites_restaurant =
            prefs.getStringList('restaruant_favorites')?.toSet() ??
                Set<String>();
        _loadFavorites_shops =
            prefs.getStringList('shop_favorites')?.toSet() ?? Set<String>();
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

  void _open_res_favScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavListRes(favorites: _loadFavorites_restaurant),
      ),
    );
  }

  void _open_shop_favScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavListShop(favorites: _loadFavorites_shops),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBottomSheetMenu(
        context, _openfavScreen, _open_res_favScreen, _open_shop_favScreen);
  }
}

Widget _buildBottomSheetMenu(BuildContext context, VoidCallback openfavScreen,
    VoidCallback open_res_favScreen, VoidCallback open_shop_favScreen) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: const Icon(Icons.favorite),
        title: const Text('Cafés Favorite'),
        onTap: openfavScreen,
        trailing: const Icon(Icons.chevron_right),
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.favorite),
        title: const Text('Restaurants Favorite'),
        onTap: open_res_favScreen,
        trailing: const Icon(Icons.chevron_right),
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.favorite),
        title: const Text('Shops Favorite'),
        onTap: open_shop_favScreen,
        trailing: const Icon(Icons.chevron_right),
      ),
    ],
  );
}
