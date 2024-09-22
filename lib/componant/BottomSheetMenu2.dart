import 'package:flutter/material.dart';
import 'package:location_api/fav_cafe.dart';
import 'package:location_api/fav_res.dart';
import 'package:location_api/fav_shop.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bottomsheetmenu2 extends StatefulWidget {
  const Bottomsheetmenu2({super.key});

  @override
  State<Bottomsheetmenu2> createState() => _BottomsheetmenuState();
}

class _BottomsheetmenuState extends State<Bottomsheetmenu2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBottomSheetMenu(context);
  }
}

Widget _buildBottomSheetMenu(BuildContext context) {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: Icon(Icons.favorite),
        title: Text('1'),
        trailing: Icon(Icons.chevron_right),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.favorite),
        title: Text('2'),
        trailing: Icon(Icons.chevron_right),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.favorite),
        title: Text('3'),
        trailing: Icon(Icons.chevron_right),
      ),
    ],
  );
}
