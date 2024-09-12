import 'package:flutter/material.dart';

class ScrollerWidget extends StatefulWidget {
  const ScrollerWidget({super.key});

  @override
  State<ScrollerWidget> createState() => _ScrollerWidgetState();
}

class _ScrollerWidgetState extends State<ScrollerWidget> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      height: 150,
      margin: EdgeInsets.all(5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Container(
              width: 300,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.home, color: textColor),
                      title: Text(
                        'Home',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        'Day off is waiting for you! GO home now.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('DIRECTION'),
                          onPressed: () {/* ... */},
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 300,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.work_history, color: textColor),
                      title: Text(
                        'Digio',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        'Back to work. your boss is waiting for you! GO now.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('DIRECTION'),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 300,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.local_convenience_store_rounded,
                          color: textColor),
                      title: Text(
                        '7-Eleven',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        'Want to eat! GO 7-11 now.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('DIRECTION'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
