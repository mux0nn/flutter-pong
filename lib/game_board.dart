import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_game/pixel.dart';
import 'package:simple_game/paddle.dart';
import 'package:simple_game/ball.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  bool _visible = false;
  int gameSpeed = 0;

  //grid dimensions
  int rowLength = 11;
  int colLength = 13;

  int score = 0;
  int ballMoveValue = 0;
  //bounceFlag is used for angle of reflection
  bool bounceFlag = false;
  bool gameOver = false;

  Color ballColor = Colors.white;
  Color paddleColor = Colors.white;

  Paddle paddle = Paddle();
  Ball ball = Ball();

  void movePaddleLeft() {
    //Keep paddle from going off the board on the left
    if (paddle.position.first == rowLength * colLength - rowLength) {
      return;
    }

    setState(() {
      for (int i = 0; i < paddle.position.length; i++) {
        paddle.position[i] -= 1;
      }
    });
  }

  void movePaddleRight() {
    //Keep paddle from going off the board ont the right
    if (paddle.position.last == rowLength * colLength - 1) {
      return;
    }

    setState(() {
      for (int i = 0; i < paddle.position.length; i++) {
        paddle.position[i] += 1;
      }
    });
  }

  void checkBounce() {
    //Move shape -> /
    if (bounceFlag) {
      if (ballMoveValue > 0) {
        ballMoveValue = 10;
      } else {
        ballMoveValue = -10;
      }
    }
    //Move shape -> \
    else {
      if (ballMoveValue > 0) {
        ballMoveValue = 12;
      } else {
        ballMoveValue = -12;
      }
    }
    bounceFlag = !bounceFlag;
  }

  void checkCollison() {
    //Check collision with the paddle
    int first = paddle.position.first - rowLength;
    int last = paddle.position.last - rowLength;
    if (ball.position >= first && ball.position <= last) {
      //Weird bounce on corners like in old school pong
      if (ball.position == first && ballMoveValue == 12) {
        ballMoveValue = -ballMoveValue;
      } else if (ball.position == last && ballMoveValue == 10) {
        ballMoveValue = -ballMoveValue;
      } else {
        checkBounce();
        ballMoveValue = -ballMoveValue;
      }
      getPoint();
    }

    //Paddle on corners
    else if (ball.position == first - 1 && ballMoveValue == 12 ||
        ball.position == last + 1 && ballMoveValue == 10) {
      ballMoveValue = -ballMoveValue;
      getPoint();
    }

    //Bottom - lose game
    else if (ball.position >= rowLength * colLength) {
      gameOver = true;
    }

    //Board Top Corners
    else if (ball.position == 0 || ball.position == rowLength - 1) {
      ballMoveValue = -ballMoveValue;
    }

    //Top
    else if (ball.position >= 0 && ball.position <= rowLength - 1) {
      checkBounce();
      ballMoveValue = -ballMoveValue;
    }

    //Left
    else if (ball.position % rowLength == 0) {
      checkBounce();
    }

    //Right
    else {
      for (int i = rowLength - 1; i < rowLength * colLength; i += rowLength) {
        if (ball.position == i) {
          checkBounce();
        }
      }
    }
  }

  void getPoint() {
    //Add point and show it on the screen for a moment
    score += 1;
    _visible = !_visible;
    Timer(Duration(milliseconds: 350), () => _visible = !_visible);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(
      Duration(milliseconds: gameSpeed),
      (timer) {
        if (gameOver) {
          timer.cancel();
          showGameOverDialog();
        }
        setState(() {
          checkCollison();
          ball.moveBall(ballMoveValue);
        });
      },
    );
  }

  void startGame() {
    ball.initalizeBall();
    paddle.initalizePaddle();

    score = 0;
    gameOver = false;
    gameSpeed = 100;
    bounceFlag = true;
    ballMoveValue = 12;
    gameOver = false;
    Duration frameRate = Duration(milliseconds: gameSpeed);
    gameLoop(frameRate);
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your Score: $score '),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: Text('Play Again', style: TextStyle(color: Colors.black)),
          ),
        ],
        elevation: 100,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(32),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                    itemCount: rowLength * colLength,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLength,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                    ),
                    itemBuilder: (context, index) {
                      //Paint paddle, ball or board
                      if (paddle.position.contains(index)) {
                        return Pixel(
                          color: paddleColor,
                        );
                      } else if (ball.position == index) {
                        return Pixel(
                          color: ballColor,
                        );
                      } else {
                        return Pixel(
                          color: Colors.grey[800],
                        );
                      }
                    }),
                AnimatedOpacity(
                  // If the widget is visible, animate to 0.0 (invisible).
                  // If the widget is hidden, animate to 1.0 (fully visible).
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(6, 6),
                            blurRadius: 10,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: movePaddleLeft,
                  color: Colors.white,
                  iconSize: 40,
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                ),
                const SizedBox(width: 40),
                IconButton(
                  onPressed: movePaddleRight,
                  color: Colors.white,
                  iconSize: 40,
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
