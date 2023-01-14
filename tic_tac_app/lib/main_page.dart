import 'package:flutter/material.dart';
import 'package:tic_tac_app/utils.dart';

class Player {
  static const none = '';
  static const X = 'X';
  static const O = 'O';
}

class MainPage extends StatefulWidget {
  final String title;
  const MainPage({Key? key, required this.title}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final countMatrix = 3;
  final double blockSize = 92;

  String lastMove = Player.none;
  late List<List<String>> matrix;

  @override
  void initState() {
    setEmptyFields();
    super.initState();
  }

  void setEmptyFields() => setState(
        () => matrix = List.generate(
          countMatrix,
          (_) => List.generate(countMatrix, (_) => Player.none),
        ),
      );

  Color getBackgroundColor() {
    final thisMove = lastMove == Player.X ? Player.O : Player.X;
    return getFieldColor(thisMove).withAlpha(150);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.title.toString()),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Utils.modeBuilder(matrix, (x, value) => buildRow(x)),
      ),
    );
  }

  buildRow(int x) {
    final values = matrix[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utils.modeBuilder(
        values,
        (y, value) => buildField(x, y),
      ),
    );
  }

  Color getFieldColor(String value) {
    switch (value) {
      case Player.O:
        return Colors.blue;
      case Player.X:
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  buildField(int x, int y) {
    final value = matrix[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(blockSize, blockSize),
          backgroundColor: color,
        ),
        onPressed: () => selectField(value, x, y),
        child: Text(
          value,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  void selectField(String value, int x, int y) {
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

      setState(() {
        lastMove = newValue;
        matrix[x][y] = newValue;
      });
      if (isWinner(x, y)) {
        showEndDialogue('Player $newValue Won!');
      } else if (isEnd()) {
        showEndDialogue('Undecided Game');
      }
    }
  }

  bool isEnd() =>
      matrix.every((values) => values.every((value) => value != Player.none));

  bool isWinner(int x, int y) {
    var col = 0, row = 0, diag = 0, rdiag = 0;
    final player = matrix[x][y];
    final n = countMatrix;

    for (int i = 0; i < n; i++) {
      if (matrix[x][i] == player) col++;
      if (matrix[i][y] == player) row++;
      if (matrix[i][i] == player) diag++;
      if (matrix[i][n - i - 1] == player) rdiag++;
    }

    return row == n || col == n || diag == n || rdiag == n;
  }

  Future showEndDialogue(String title) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: const Text('Press to restart the game'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setEmptyFields();
                Navigator.of(context).pop();
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      );
}
