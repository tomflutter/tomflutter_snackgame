import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(SnackGameApp());
}

class SnackGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tom Snack Game',
      home: SnackGameScreen(),
    );
  }
}

class SnackGameScreen extends StatefulWidget {
  @override
  _SnackGameScreenState createState() => _SnackGameScreenState();
}

class _SnackGameScreenState extends State<SnackGameScreen> {
  static const int gridSize = 25;
  static const double cellSize = 30.0;
  List<int> snake = [45, 44, 43]; // Initial position of the snake
  int food = Random().nextInt(gridSize * gridSize); // Initial position of the food
  Direction direction = Direction.right;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    const duration = Duration(milliseconds: 300);
    Timer.periodic(duration, (Timer timer) {
      if (isGameOver) {
        timer.cancel();
        _showGameOverDialog();
      } else {
        moveSnake();
        checkCollision();
        setState(() {});
      }
    });
  }

  void moveSnake() {
    final head = snake.first;
    int newHead;

    switch (direction) {
      case Direction.up:
        newHead = (head - gridSize) % (gridSize * gridSize);
        break;
      case Direction.down:
        newHead = (head + gridSize) % (gridSize * gridSize);
        break;
      case Direction.left:
        newHead = (head - 1) % gridSize == gridSize - 1 ? head - 1 + gridSize : head - 1;
        break;
      case Direction.right:
        newHead = (head + 1) % gridSize == 0 ? head + 1 - gridSize : head + 1;
        break;
    }

    snake.insert(0, newHead);

    if (newHead == food) {
      generateFood();
    } else {
      snake.removeLast();
    }
  }

  void checkCollision() {
    if (snake.length > Set<int>.from(snake).length || snake.any((cell) => cell < 0 || cell >= gridSize * gridSize)) {
      isGameOver = true;
    }
  }

  void generateFood() {
    food = Random().nextInt(gridSize * gridSize);
    while (snake.contains(food)) {
      food = Random().nextInt(gridSize * gridSize);
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Score Kamu: ${snake.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Mulai Lagi?'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      snake = [45, 44, 43];
      food = Random().nextInt(gridSize * gridSize);
      direction = Direction.right;
      isGameOver = false;
    });
    startGame();
  }

  void changeDirection(Direction newDirection) {
    // Prevent the snake from going in the opposite direction
    if ((direction == Direction.up && newDirection != Direction.down) ||
        (direction == Direction.down && newDirection != Direction.up) ||
        (direction == Direction.left && newDirection != Direction.right) ||
        (direction == Direction.right && newDirection != Direction.left)) {
      direction = newDirection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tom Snack Game'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/1.jpg"), // Sesuaikan dengan path gambar yang sesuai
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! > 0 && direction != Direction.up) {
                    changeDirection(Direction.down);
                  } else if (details.primaryDelta! < 0 && direction != Direction.down) {
                    changeDirection(Direction.up);
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.primaryDelta! > 0 && direction != Direction.left) {
                    changeDirection(Direction.right);
                  } else if (details.primaryDelta! < 0 && direction != Direction.right) {
                    changeDirection(Direction.left);
                  }
                },
                child: Container(
                  width: gridSize * cellSize,
                  height: gridSize * cellSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0), // Lebar garis dapat diatur di sini
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final isSnakeCell = snake.contains(index);
                      final isFoodCell = food == index;
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: isSnakeCell ? Colors.green : (isFoodCell ? Colors.orangeAccent : null),
                          border: Border.all(color: Colors.black),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // Jarak antara Expanded dan tombol atas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    changeDirection(Direction.up);
                  },
                  child: Icon(Icons.arrow_upward),
                ),
              ],
            ),
            SizedBox(height: 16), // Jarak antara tombol tengah dan tombol bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    changeDirection(Direction.left);
                  },
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    changeDirection(Direction.right);
                  },
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
            SizedBox(height: 16), // Jarak antara tombol tengah dan tombol bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    changeDirection(Direction.down);
                  },
                  child: Icon(Icons.arrow_downward),
                ),
              ],
            ),
            SizedBox(height: 16), // Jarak antara tombol tengah dan tombol bawah
          ],
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }
