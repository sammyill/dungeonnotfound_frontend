import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gamechats/game_chat_srd.dart';
import 'dart:math';

void main() {
  runApp(
    // Add ProviderScope above your app
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dungeon Not Found',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GameChatPageSRD(),
    );
  }
}

//thi class will be removed from here and placed in the backend in c#

class GetExponentTable {
  final double xBase;
  final double exponent;
  final int maxLevel;
  GetExponentTable({this.xBase = 1.5, this.exponent = 1.4, this.maxLevel = 20});

  Map<String, int> createExTable() {
    Map<String, int> levelTable = {};
    double currentMultiplier = pow(xBase, exponent).toDouble();
    for (int i = 1; i <= maxLevel; i++) {
      double levelExp = i * currentMultiplier;
      levelTable["$i"] = levelExp.toInt();
      currentMultiplier = currentMultiplier * exponent;
    }

    return levelTable;
  }
}
