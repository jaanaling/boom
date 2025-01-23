import 'dart:async';
import 'dart:math';

import 'package:booms/src/core/utils/app_icon.dart';
import 'package:booms/src/core/utils/icon_provider.dart';
import 'package:booms/src/core/utils/log.dart';
import 'package:booms/src/core/utils/size_utils.dart';
import 'package:booms/src/core/utils/text_with_border.dart';
import 'package:booms/src/feature/rituals/bloc/user_bloc.dart';
import 'package:booms/src/feature/rituals/presentation/home_screen.dart';
import 'package:booms/src/feature/rituals/presentation/selection_screen.dart';
import 'package:booms/ui_kit/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Экран игры
class GameScreen extends StatefulWidget {
  /// Поле size x size (например, size=10 => поле 10x10)
  final int size;

  const GameScreen({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<GameScreen> {
  /// Двумерный массив ячеек
  late List<List<Cell>> _board;
  int openedCells = 0;
  int flagsPlaced = 0;
  bool usedShield = false;
  bool usedMagnifier = false;

  /// Количество мин
  late int _mineCount;

  /// Состояние игры
  bool _gameOver = false;
  bool _gameWon = false;

  /// Бонусы
  bool _shieldActive = true;
  bool _magnifierAvailable = true;
  bool _autoWinAvailable = true;

  /// Таймер (обратный отсчёт)
  Timer? _timer;
  late int _timeLeft; // Осталось секунд
  late int _totalTime; // Для вычисления оценки в конце

  /// Итоговая оценка (1..5)
  int? _finalRating;

  /// Размер клетки в пикселях (фиксированный)
  static const double cellSize = 60.0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  /// Начинаем новую игру
  void _startNewGame() {
    _gameOver = false;
    _gameWon = false;
    _finalRating = null;

    // Сбрасываем бонусы
    _shieldActive = true;
    _magnifierAvailable = true;
    _autoWinAvailable = true;

    // Вычисляем кол-во мин (примерно 15% от всех клеток)
    _mineCount = (widget.size * widget.size * 0.15).floor();

    // Генерируем поле
    _board = _generateBoard(widget.size, widget.size, _mineCount);

    // Запускаем таймер (примерная формула: size * size * 2 секунд)
    _totalTime = widget.size * widget.size * 2;
    _timeLeft = _totalTime;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameOver || _gameWon) {
        timer.cancel();
        _showResultDialog();
        return;
      }
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          _gameOver = true;

          _stopTimer();
        }
      });
    });

    setState(() {});
  }

  /// Генерация поля
  List<List<Cell>> _generateBoard(int rows, int cols, int mineCount) {
    // 1. Создаём пустые клетки
    final List<List<Cell>> board = List.generate(
      rows,
      (_) => List.generate(cols, (_) => Cell()),
    );

    // 2. Случайно расставляем мины
    final random = Random();
    int placedMines = 0;
    while (placedMines < mineCount) {
      final int r = random.nextInt(rows);
      final int c = random.nextInt(cols);
      if (!board[r][c].isMine) {
        board[r][c].isMine = true;
        placedMines++;
      }
    }

    // 3. Считаем количество соседних мин
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!board[r][c].isMine) {
          board[r][c].adjacentMines = _countMinesAround(board, r, c);
        }
      }
    }

    return board;
  }

  /// Подсчёт мин вокруг (для [row,col])
  int _countMinesAround(List<List<Cell>> board, int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final int nr = row + dr;
        final int nc = col + dc;
        if (_isInsideBoard(nr, nc) && board[nr][nc].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  /// В пределах доски?
  bool _isInsideBoard(int row, int col) {
    return row >= 0 && row < widget.size && col >= 0 && col < widget.size;
  }

  /// Нажатие (открыть ячейку)
  void _revealCell(int row, int col) {
    if (_gameOver || _gameWon) return;
    final cell = _board[row][col];

    // Если уже открыта или помечена флагом, выходим
    if (cell.isRevealed || cell.isFlagged) return;

    setState(() {
      cell.isRevealed = true;
      openedCells++;
    });

    // Если это мина
    if (cell.isMine) {
      if (_shieldActive) {
        // Один раз спасаем
        _shieldActive = false;
      } else {
        // Щита нет – проигрыш
        _gameOver = true;
        _revealAllMines();
        _stopTimer();
        return;
      }
    } else {
      // Если нет мин рядом (adjacentMines == 0), рекурсивно открываем соседей
      if (cell.adjacentMines == 0) {
        _revealEmptyCells(row, col);
      }
    }

    _checkWinCondition();
  }

  /// Рекурсивное открытие "пустых" ячеек
  void _revealEmptyCells(int row, int col) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final int nr = row + dr;
        final int nc = col + dc;
        if (_isInsideBoard(nr, nc)) {
          final neighbor = _board[nr][nc];
          if (!neighbor.isRevealed && !neighbor.isMine && !neighbor.isFlagged) {
            neighbor.isRevealed = true;
            if (neighbor.adjacentMines == 0) {
              openedCells++;
              _revealEmptyCells(nr, nc);
            }
          }
        }
      }
    }
  }

  /// Долгое нажатие (поставить/снять флаг)
  void _toggleFlag(int row, int col) {
    if (_gameOver || _gameWon) return;
    final cell = _board[row][col];

    // Если ещё не открыта, можно флажок ставить/снимать
    if (!cell.isRevealed) {
      setState(() {
        if (cell.isFlagged) {
          flagsPlaced--;
        } else {
          flagsPlaced++;
        }
        cell.isFlagged = !cell.isFlagged;
      });
    }
  }

  /// Раскрыть все мины (при проигрыше)
  void _revealAllMines() {
    for (var row in _board) {
      for (var cell in row) {
        if (cell.isMine) {
          cell.isRevealed = true;
        }
      }
    }
  }

  /// Проверка – не выиграли ли мы
  void _checkWinCondition() {
    for (var row in _board) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          return;
        }
      }
    }
    // Если все не-минные открыты – победа
    _gameWon = true;

    _stopTimer();
    _calculateRating();
    context.read<UserBloc>().add(
          UserPuzzleSolved(
            isCorrect: true,
            score: _finalRating!,
            openedCells: openedCells,
            flagsPlaced: flagsPlaced,
            usedShield: usedShield,
            usedMagnifier: usedMagnifier,
            timeSpent: _totalTime - _timeLeft,
          ),
        );
  }

  /// Остановка таймера
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _showResultDialog();
  }

  /// Расчёт итоговой оценки (1..5), зависит от оставшегося времени
  void _calculateRating() {
    // Пример: делим всё время на 5 "отрезков"
    final double fraction = _timeLeft / _totalTime; // от 0 до 1
    if (fraction >= 0.8) {
      _finalRating = 5;
    } else if (fraction >= 0.6) {
      _finalRating = 4;
    } else if (fraction >= 0.4) {
      _finalRating = 3;
    } else if (fraction >= 0.2) {
      _finalRating = 2;
    } else {
      _finalRating = 1;
    }
  }

  /// Использование лупы (показать одну нераскрытую/нефлагнутую мину)
  void _useMagnifier() {
    if (!_magnifierAvailable || _gameOver || _gameWon) return;

    // Находим нераскрытые и не помеченные мины
    final List<Cell> hiddenMines = [];
    context.read<UserBloc>().add(UserRemoveCoins(20));

    for (var row in _board) {
      for (var cell in row) {
        if (cell.isMine && !cell.isRevealed && !cell.isFlagged) {
          hiddenMines.add(cell);
        }
      }
    }
    if (hiddenMines.isEmpty) {
      // Нет подходящих мин
      return;
    }

    // Выбираем случайно одну и открываем
    final random = Random();
    final Cell chosen = hiddenMines[random.nextInt(hiddenMines.length)];
    setState(() {
      chosen.isRevealed = true;
      usedMagnifier = true;
    });
  }

  /// Использование авто-победы
  void _useAutoWin() {
    if (!_autoWinAvailable || _gameOver || _gameWon) return;
    setState(() {
      context.read<UserBloc>().add(UserRemoveCoins(50));
      _autoWinAvailable = false;
      _gameWon = true;
      // Раскрываем всё поле
      for (var row in _board) {
        for (var cell in row) {
          cell.isRevealed = true;
        }
      }

      _stopTimer();
      _calculateRating();
    });
  }

  /// Показать кастомный диалог с результатом игры
  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: !_gameWon ? 200 : 410,
            width: 450,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  child: Container(
                    height: !_gameWon ? 150 : 350,
                    width: 450,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(IconProvider.panel.buildImageUrl()),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _gameWon
                                ? 'You Won!\n$_timeLeft seconds saved!'
                                : 'You Lost!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Purple',
                              fontSize: 37,
                              color: Colors.white,
                            ),
                          ),
                          if (_gameWon) const Gap(20),
                          if (_gameWon)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const TextWithBorder(
                                  "+5",
                                  fontSize: 50,
                                ),
                                const Gap(15),
                                Transform(
                                  transform: Matrix4.identity()
                                    ..translate(0.0)
                                    ..rotateZ(0.26),
                                  child: AppIcon(
                                    asset: IconProvider.coins.buildImageUrl(),
                                    width: 50,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AppButton(
                    width: getWidth(context, percent: 0.5),
                    height: 59,
                    onPressed: () {
                      if (_gameWon) {
                        context
                          ..pop()
                          ..pop();
                      } else {
                        context.pop();
                        _startNewGame();
                      }
                    },
                    child: TextWithBorder(
                      _gameWon ? 'CONTINUE' : 'TRY AGAIN',
                      fontSize: 30,
                    ),
                  ),
                ),
                if (_finalRating != null && _gameWon)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Star(
                      score: _finalRating!,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Показать кастомный диалог для подтверждения использования бустера
  void _showBoosterDialog(
    VoidCallback onConfirm,
    String boosterName,
    String describe,
  ) async {
    final coins = (context.read<UserBloc>().state as UserLoaded).user.coins;
    logger.d(coins);
    if (coins < 10 && boosterName == "Shield") {
      _showNotEnoughCoinsDialog(boosterName);
      return;
    }
    if (coins < 20 && boosterName == "Metal detector") {
      _showNotEnoughCoinsDialog(boosterName);
      return;
    }
    if (coins < 50 && boosterName == "Rocket") {
      _showNotEnoughCoinsDialog(boosterName);
      return;
    }
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 350,
            width: 450,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 310,
                  width: 450,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(IconProvider.panel.buildImageUrl()),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Use $boosterName?\n\n$describe',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Purple',
                            fontSize: 27,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AppButton(
                        width: getWidth(context, percent: 0.3),
                        height: 59,
                        onPressed: () {
                          context.pop();
                        },
                        child: const TextWithBorder(
                          'CANCEL',
                          fontSize: 15,
                        ),
                      ),
                      AppButton(
                        width: getWidth(context, percent: 0.3),
                        height: 59,
                        onPressed: () {
                          onConfirm();
                          context.pop();
                        },
                        child: const TextWithBorder(
                          'CONFIRM',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppButton(
                          width: 58,
                          height: 58,
                          onPressed: () {
                            context.pop();
                          },
                          child: AppIcon(
                            asset: IconProvider.arrow.buildImageUrl(),
                            width: 32,
                            height: 40,
                          ),
                        ),
                        const Gap(10),
                        AppButton(
                          width: 58,
                          height: 58,
                          onPressed: () {
                            _startNewGame();
                          },
                          child: const Icon(
                            Icons.refresh,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AppIcon(
                            asset: IconProvider.time.buildImageUrl(),
                            width: 92,
                            height: 92,
                          ),
                          CustomPaint(
                            size: const Size(75, 75),
                            painter: TimerPainter(
                              progress: _timeLeft / _totalTime,
                              backgroundColor: Colors.transparent,
                              progressColor: Colors.green,
                            ),
                          ),
                          // Центр (можно добавить текст)
                          Center(
                            child: TextWithBorder(
                              (_timeLeft).toString(),
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CoinsRow(
                      coins: state.user.coins,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: getWidth(context, percent: 1),
                height: getHeight(context, percent: 0.58),
                child: _buildBoard(),
              ),
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  /// Использование щита (защита от одной мины)
  void _useShield() {
    if (!_shieldActive || _gameOver || _gameWon) return;
    setState(() {
      context.read<UserBloc>().add(UserRemoveCoins(10));
      _shieldActive = false;
      usedShield = true;
    });
  }

  /// Показать кастомный диалог, если щит уже используется
  Future<void> _showShieldUsedDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 300,
            width: 450,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  width: 450,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(IconProvider.panel.buildImageUrl()),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Shield is already used!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Purple',
                            fontSize: 27,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AppButton(
                    width: getWidth(context, percent: 0.3),
                    height: 59,
                    onPressed: () {
                      context.pop();
                    },
                    child: const TextWithBorder(
                      'OK',
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Показать кастомный диалог, если не хватает монет для использования бустера
  void _showNotEnoughCoinsDialog(String boosterName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 300,
            width: 450,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  width: 450,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(IconProvider.panel.buildImageUrl()),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Not enough coins to use $boosterName!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Purple',
                            fontSize: 27,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AppButton(
                    width: getWidth(context, percent: 0.3),
                    height: 59,
                    onPressed: () {
                      context.pop();
                    },
                    child: const TextWithBorder(
                      'OK',
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Нижняя панель с информацией и бонусами
  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bosterBuild(
          _shieldActive
              ? () => _showBoosterDialog(
                    _useShield,
                    "Shield",
                    "Protects you from a single nail",
                  )
              : () => _showShieldUsedDialog(),
          '10',
          IconProvider.shield.buildImageUrl(),
        ),
        bosterBuild(
          () => _showBoosterDialog(
            _useMagnifier,
            "Metal detector",
            "Looking for and opening one nail",
          ),
          '20',
          IconProvider.detector.buildImageUrl(),
        ),
        bosterBuild(
          () => _showBoosterDialog(
            _useAutoWin,
            "Rocket",
            "You fly through this level by saving all the balloons",
          ),
          '50',
          IconProvider.rocket.buildImageUrl(),
        ),
      ],
    );
  }

  GestureDetector bosterBuild(VoidCallback? func, String text, String asset) {
    return GestureDetector(
      onTap: func,
      child: Column(
        children: [
          Row(
            children: [
              TextWithBorder(
                text,
                fontSize: 30,
              ),
              const Gap(10),
              Transform(
                transform: Matrix4.identity()
                  ..translate(0.0)
                  ..rotateZ(0.26),
                child: AppIcon(
                  asset: IconProvider.coins.buildImageUrl(),
                  width: 30,
                ),
              ),
            ],
          ),
          const Gap(15),
          AppIcon(
            asset: asset,
            width: 70,
          ),
        ],
      ),
    );
  }

  /// Построение поля с фиксированным размером клеток и скроллом в обе стороны
  Widget _buildBoard() {
    final size = widget.size;

    // Общие габариты: size * cellSize
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: SizedBox(
            width: size * cellSize,
            height: size * cellSize,
            child: Center(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: size * size,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size,
                  // Соотношение сторон 1:1, чтобы клетки были квадратными
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ size;
                  final col = index % size;
                  final cell = _board[row][col];
                  return GestureDetector(
                    onTap: () => _revealCell(row, col),
                    onLongPress: () => _toggleFlag(row, col),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        image: !cell.isRevealed
                            ? DecorationImage(
                                image: AssetImage(
                                  IconProvider.balloon.buildImageUrl(),
                                ),
                                fit: BoxFit.fitHeight,
                                colorFilter: cell.isFlagged
                                    ? ColorFilter.mode(
                                        Colors.red.withOpacity(0.7),
                                        BlendMode.srcATop,
                                      )
                                    : null,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: _buildCellContent(cell),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Отображение содержимого клетки
  Widget _buildCellContent(Cell cell) {
    // Если клетка не раскрыта
    if (!cell.isRevealed) {
      // Может быть флаг
      if (cell.isFlagged) {
        return AppIcon(
          asset: IconProvider.mins.buildImageUrl(),
          width: 25,
        );
      }
      return const SizedBox.shrink();
    }

    // Если раскрыта и это мина
    if (cell.isMine) {
      return AppIcon(
        asset: IconProvider.mins.buildImageUrl(),
      );
    }

    // Если раскрыта, но не мина
    if (cell.adjacentMines > 0) {
      return TextWithBorder(cell.adjacentMines.toString(),
          fontSize: 37,
          fontFamily: 'One',
          color: _getNumberColor(cell.adjacentMines),
          borderColor: Colors.black);
    }

    // 0 мин вокруг – пустая ячейка
    return const SizedBox.shrink();
  }

  /// Цвет чисел (визуальная часть)
  Color _getNumberColor(int minesAround) {
    switch (minesAround) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.deepPurple;
      case 5:
        return Colors.brown;
      default:
        return Colors.black;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Модель одной ячейки
class Cell {
  bool isMine; // Мина?
  bool isRevealed; // Раскрыта?
  bool isFlagged; // Флажок?
  int adjacentMines; // Кол-во мин вокруг

  Cell({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Рисуем фон (круг)
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);

    // Рисуем прогресс
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2,
    );
    final startAngle = -90 * 3.1415927 / 180;
    final sweepAngle = 360 * progress * 3.1415927 / 180;

    canvas.drawArc(rect, startAngle, sweepAngle, true, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
