import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/screens/game_screen.dart';
import 'package:flutter_speedcard_app/widgets/difficulty_selector.dart';

class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({super.key});

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen> {
  Difficulty _selectedDifficulty = Difficulty.normal;
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Speed',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  DifficultySelector(
                    selected: _selectedDifficulty,
                    onChanged: (difficulty) {
                      setState(() {
                        _selectedDifficulty = difficulty;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isStarting ? null : _startGame,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: AnimatedSwitcher(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 150),
                          child: _isStarting
                              ? const SizedBox(
                                  key: ValueKey<String>('starting'),
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Start Game',
                                  key: ValueKey<String>('start'),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startGame() async {
    if (_isStarting) {
      return;
    }

    setState(() {
      _isStarting = true;
    });

    ref.read(gameProvider.notifier).startGame(_selectedDifficulty);
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    await Navigator.of(context).push(_gameRoute(reduceMotion));
    if (!mounted) {
      return;
    }

    setState(() {
      _isStarting = false;
    });
  }

  Route<void> _gameRoute(bool reduceMotion) {
    if (reduceMotion) {
      return MaterialPageRoute(builder: (_) => const GameScreen());
    }

    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const GameScreen(),
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }
}
