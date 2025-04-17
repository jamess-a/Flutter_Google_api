import 'package:flutter/material.dart';
import 'package:location_api/screen/fav_cafe.dart';
import 'package:location_api/screen/fav_res.dart';
import 'package:location_api/screen/fav_shop.dart';
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return _buildBottomSheetMenu(context);
          },
        );
      },
      child: const Card(
        margin: EdgeInsets.only(left: 5, right: 5),
        elevation: 5,
        child: ListTile(
          leading: Icon(Icons.local_taxi),
          title: Text('Taxi Tap Now'),
          subtitle: Text('See what is waiting for you! GO get it now!'),
        ),
      ),
    );
  }

  Widget _buildBottomSheetMenu(
    BuildContext context,
  ) {
    return const SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Texi Favorite'),
            trailing: const Icon(Icons.local_taxi),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Car Favorite'),
            trailing: const Icon(Icons.car_repair),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Bus Favorite'),
            trailing: const Icon(Icons.bus_alert_outlined),
          ),
        ],
      ),
    );
  }
}
