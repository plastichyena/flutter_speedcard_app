import 'package:flutter/material.dart';
import 'package:flutter_speedcard_app/screens/game_screen.dart';
import 'package:flutter_speedcard_app/screens/title_screen.dart';

import 'theme/app_theme.dart';

class SpeedCardApp extends StatelessWidget {
  const SpeedCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Card',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const TitleScreen(),
      routes: {GameScreen.routeName: (_) => const GameScreen()},
    );
  }
}
