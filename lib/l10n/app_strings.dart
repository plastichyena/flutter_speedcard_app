import '../models/enums.dart';

class AppStrings {
  const AppStrings._();

  static String get(AppLocale locale, String key) {
    return _strings[locale]![key] ?? key;
  }

  static const Map<AppLocale, Map<String, String>> _strings = {
    AppLocale.ja: _ja,
    AppLocale.en: _en,
  };

  static const Map<String, String> _ja = {
    'app_title': 'スピード',
    'start_game': 'ゲーム開始',
    'easy': 'かんたん',
    'normal': 'ふつう',
    'hard': 'むずかしい',
    'cpu_draw': 'CPU山札',
    'your_draw': 'あなたの山札',
    'phase_ready': '準備中',
    'phase_playing': 'プレイ中',
    'phase_stalemate': '詰み',
    'phase_finished': '終了',
    'stalemate_title': '詰み！',
    'stalemate_button': '仕切り直し',
    'result_human_win': 'あなたの勝ち！',
    'result_cpu_win': 'CPUの勝ち…',
    'result_draw': '引き分け',
    'restart': 'タイトルへ',
  };

  static const Map<String, String> _en = {
    'app_title': 'Speed',
    'start_game': 'Start Game',
    'easy': 'Easy',
    'normal': 'Normal',
    'hard': 'Hard',
    'cpu_draw': 'CPU Draw',
    'your_draw': 'Your Draw',
    'phase_ready': 'Ready',
    'phase_playing': 'Playing',
    'phase_stalemate': 'Stalemate',
    'phase_finished': 'Finished',
    'stalemate_title': 'Stalemate!',
    'stalemate_button': 'Resume (Reset)',
    'result_human_win': 'You Win!',
    'result_cpu_win': 'CPU Wins!',
    'result_draw': 'Draw!',
    'restart': 'Restart',
  };
}
