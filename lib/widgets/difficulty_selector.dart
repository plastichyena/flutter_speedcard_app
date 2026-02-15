import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/app_theme.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Difficulty.values.map((difficulty) {
        final bool isSelected = difficulty == selected;
        return ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: ChoiceChip(
            label: Text(_difficultyLabel(difficulty)),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppTheme.selectedCardBorder.withValues(alpha: 0.35),
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            side: BorderSide(
              color: isSelected ? AppTheme.selectedCardBorder : Colors.white30,
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            onSelected: (_) => onChanged(difficulty),
          ),
        );
      }).toList(),
    );
  }
}

String _difficultyLabel(Difficulty difficulty) {
  return switch (difficulty) {
    Difficulty.easy => 'Easy',
    Difficulty.normal => 'Normal',
    Difficulty.hard => 'Hard',
  };
}
