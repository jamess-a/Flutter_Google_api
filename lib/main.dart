import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location.dart';
import 'cafe.dart';
import 'map.dart';
import 'restaurant.dart';
import 'suggestion.dart';
import 'shop.dart';
import 'scroller.dart';
import 'fav_cafe.dart';
import 'componant/BottomSheetMenu.dart';
import 'Lab/map.dart';
import 'componant/DialogMenu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'After You!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 166, 255, 0)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 166, 255, 0),
            brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'After You!',
        onThemeChanged: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  final String title;
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<String> _favorites = Set<String>();

  @override
  void initState() {
    super.initState();
  }

  void _openMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const MapMyHomePage(
                title: 'Map',
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color containerColor = isDarkMode ? Colors.grey : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
            activeColor: Colors.white,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return const Bottomsheetmenu();
            },
          );
        },
        child: Icon(Icons.menu),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 21),
                    child: Icon(Icons.location_on),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 21),
                    child: Text(
                      'Find Your Place around You !!',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: _openMapScreen,
                          child: const Text('Open Map'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CafeListWidget()),
                            );
                          },
                          child: const Text('Café List'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RestaurantListWidget()),
                            );
                          },
                          child: const Text('Restaurant List'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShopListWidget()),
                            );
                          },
                          child: const Text('Shop List'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: ScrollerWidget(),
              ),
              Container(
                height: 450,
                child: SuggestionWidget(),
              ),
              Container(
                child: DialogWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
