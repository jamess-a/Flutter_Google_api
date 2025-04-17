import 'package:flutter/material.dart';
import 'package:location_api/screen/fav_cafe.dart';
import 'package:location_api/screen/fav_res.dart';
import 'package:location_api/screen/fav_shop.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Detailsheetmenu extends StatefulWidget {
  const Detailsheetmenu({super.key});

  @override
  State<Detailsheetmenu> createState() => _BottomsheetmenuState();
}

class _BottomsheetmenuState extends State<Detailsheetmenu> {
  Set<String> _favorites = Set<String>();
  Set<String> _loadFavorites_restaurant = Set<String>();
  Set<String> _loadFavorites_shops = Set<String>();

  @override
  void initState() {
    super.initState();
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
