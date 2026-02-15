import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/models/enums.dart';

final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.ja);
