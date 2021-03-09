import 'package:crossword_app/classes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossword Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
        CrosswordGridEditorWindow(),

    );
  }
}

class PaintTest extends StatefulWidget {
  @override
  _PaintTestState createState() => _PaintTestState();
}

class _PaintTestState extends State<PaintTest> {

  bool doubleTapDown = false;
  Offset doubleTapPosition;
  Offset currentPosition;


  @override
  Widget build(BuildContext context) {

    return Container(
      child: GestureDetector(
          child: !doubleTapDown ? Container(height: 400, width: 400, color: Colors.yellow,) :
          CustomPaint(
            size: Size(400,400),
            foregroundPainter: MyPainter(doubleTapPosition, currentPosition),),
        onLongPressStart: (details){
          setState(() {
            doubleTapDown = true;
            doubleTapPosition = details.globalPosition;
            print('DOWN');
          });

        },
        onLongPressMoveUpdate: (details){
          setState(() {
            currentPosition = details.globalPosition;
          });
        },
        onLongPressEnd: (details){
            setState(() {

              doubleTapDown = false;
              print('UP');
            });

        },),
    );
  }
}


class CrosswordGridEditorWindow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: InteractiveViewer(
          minScale: 0.01,
          maxScale: 200,
          constrained: false,
          child: CrosswordGridEditor(),
        )
    );
  }
}

class CrosswordGridEditor extends StatefulWidget {

  final CrosswordPuzzleBuilder builder = new CrosswordPuzzleConcreteBuilder(8, 8);

  @override
  _CrosswordGridEditorState createState() => _CrosswordGridEditorState();
}

class _CrosswordGridEditorState extends State<CrosswordGridEditor> {
  final double dim = 50;

  bool doubleTapDown = false;
  Offset doubleTapPosition;
  Offset currentPosition;

  @override
  Widget build(BuildContext context) {

    CrosswordPuzzle puzzle = widget.builder.getPuzzle();

    List<TableRow> crosswordGridRows = [];

    for(int i = 0; i<puzzle.rows; i++){

      List<Widget> rowContents = [];

      for(int j = 0; j<puzzle.cols; j++){

        String c = puzzle.getCharAtPosition(i, j);
        bool isEmpty = c == '';

        int clueNumber = puzzle.getClueNumberAtPosition(i,j);
        String clueNumberText = clueNumber == null ? '' : clueNumber.toString() + '. ';

        // Individual grid squares
        Widget square = new Container(
            child: Text(clueNumberText + c),
            width: dim,
            height: dim,
            decoration: BoxDecoration(border: Border.all(), color: isEmpty ? Colors.black : Colors.white)
        );

        square = GestureDetector(
          child: square,
          onTap: () {
            setState(() {
              widget.builder.toggleSquareAtPosition(i, j);
            });
          },
        );

        rowContents.add(square);
      }

      TableRow crosswordGridRow = new TableRow(children: rowContents);
      crosswordGridRows.add(crosswordGridRow);

    }

    Widget table = Table(
      children: crosswordGridRows,
      defaultColumnWidth: FixedColumnWidth(dim),
    );

    table = CustomPaint(
      foregroundPainter: MyPainter(doubleTapPosition, currentPosition),
      child: table,
    );

    // Gesture detector for long press (easy multi-select)
    table = GestureDetector(
      child: table,
      onLongPressStart: (details){
        setState(() {
          doubleTapDown = true;
          doubleTapPosition = details.localPosition;
        });

      },
      onLongPressMoveUpdate: (details){
        setState(() {
          currentPosition = details.localPosition;
        });
      },
      onLongPressEnd: (details){
        setState(() {
          doubleTapDown = false;
          doubleTapPosition = null;
          currentPosition = null;
        });

      },);

    return table;

  }
}

class MyPainter extends CustomPainter {
  final Offset doubleTapPosition;
  final Offset currentPosition;

  MyPainter(this.doubleTapPosition, this.currentPosition);

  @override
  void paint(Canvas canvas, Size size) {
    if(doubleTapPosition == null || currentPosition == null) return;
    final p1 = doubleTapPosition;
    final p2 = currentPosition;
    final paint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);
    print('PAINTING: ' + doubleTapPosition.toString() + ' TO ' + currentPosition.toString());
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}