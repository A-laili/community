import 'package:flutter/material.dart';
import 'package:vid/pages/feeds_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Feeds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FeedsPage(),
    );
  }
}
