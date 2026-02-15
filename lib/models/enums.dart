enum Suit { spade, heart, diamond, club }

enum Rank {
  ace(1),
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9),
  ten(10),
  jack(11),
  queen(12),
  king(13);

  const Rank(this.value);

  final int value;
}

enum GamePhase { ready, playing, stalemate, finished }

enum Difficulty { easy, normal, hard }

enum Player { human, cpu }

enum CenterPile { left, right }

enum GameResult { humanWin, cpuWin, draw }
