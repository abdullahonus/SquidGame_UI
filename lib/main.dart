import 'package:flutter/material.dart';
import 'package:squid_game/squid_game.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Countrol4Offical',
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            title: const Text('Squied GAME'),
          ),
          body: SquidGame()),
    );
  }
}
