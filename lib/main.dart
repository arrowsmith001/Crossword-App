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

  CrosswordGridEditorWindow window;

  @override
  Widget build(BuildContext context) {

    window = new CrosswordGridEditorWindow();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
        window,
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


class CrosswordGridEditorWindow extends StatefulWidget {

  @override
  _CrosswordGridEditorWindowState createState() => _CrosswordGridEditorWindowState();

}

class _CrosswordGridEditorWindowState extends State<CrosswordGridEditorWindow> {
  final CrosswordPuzzleBuilder builder = new CrosswordPuzzleConcreteBuilder(12, 12);

  bool editingClues = false;

  void editClues() {
    setState(() {
      editingClues = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    int defaultCols = 12;

    const margin = 8.0;
    double screenWidth = MediaQuery.of(context).size.width;

    double defaultDim = (screenWidth - 2*margin) / defaultCols;

    return Stack(
      children: [
        Column(
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(margin),
              child: InteractiveViewer(
                  minScale: 0.2,
                  maxScale: 5,
                  constrained: true,
                  child: CrosswordGridEditor(builder, defaultDim)
                //Container(height: 200, width: 200, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue, Colors.red, Colors.white])),)
              ),
            ),
          ),

          !editingClues ? Container()
              : Flexible(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: builder.getHandler().getNumberOfAcrossClues(),
                        itemBuilder: (context, i) {
                          CrosswordPuzzleHandler handler = builder.getHandler();
                          Clue clue = handler.getAcrossClue(i);

                          return ListTile(
                            leading: Text(clue.clueNumber.toString()),
                            title: Text(clue.description),
                            trailing: Text('(' + clue.length.toString() + ')'),
                          );
                        }),),

                  Expanded(
                    child: ListView.builder(
                        itemCount: builder.getHandler().getNumberOfDownClues(),
                        itemBuilder: (context, i) {
                          CrosswordPuzzleHandler handler = builder.getHandler();
                          Clue clue = handler.getDownClue(i);

                          return ListTile(
                            leading: Text(clue.clueNumber.toString()),
                            title: Text(clue.description),
                            trailing: Text('(' + clue.length.toString() + ')'),
                          );
                        }),)
                ],
              )
          )

        ],
      ),

        FloatingActionButton(
          child: Icon(Icons.check_circle_outline),
          onPressed: (){
            editClues();
          },
        )

      ],
    );
  }
}

class CrosswordGridEditor extends StatefulWidget {

  CrosswordGridEditor(this.builder, this.defaultDim);

  final CrosswordPuzzleBuilder builder;
  final double defaultDim;

  @override
  _CrosswordGridEditorState createState() => _CrosswordGridEditorState();
}

class _CrosswordGridEditorState extends State<CrosswordGridEditor> {

  bool longPressDown = false;
  Offset longPressPosition;
  Offset currentPosition;


  void toggleSquareAtPosition(int i, int j) {
    setState(() {
      widget.builder.toggleSquareAtPosition(i, j);
    });
  }

  @override
  Widget build(BuildContext context) {

    CrosswordPuzzleBuilder builder = widget.builder;
    CrosswordPuzzleHandler handler = builder.getHandler();

    List<TableRow> crosswordGridRows = [];

    for(int i = 0; i<handler.getRows(); i++){

      List<Widget> rowContents = [];

      for(int j = 0; j<handler.getCols(); j++){

        String c = handler.getCharAtPosition(i, j);
        int clueNumber = handler.getClueNumberAtPosition(i,j);
        String clueNumberText = clueNumber == null ? '' : clueNumber.toString() + '. ';

        // Individual grid squares
        Widget square = SingleGridSquare(this, i, j, widget.defaultDim, c, clueNumber, clueNumberText);
        rowContents.add(square);
      }

      TableRow crosswordGridRow = new TableRow(children: rowContents, decoration: BoxDecoration(color: Colors.black));
      crosswordGridRows.add(crosswordGridRow);

    }

    Widget table = Table(
      children: crosswordGridRows,
      defaultColumnWidth: FixedColumnWidth(widget.defaultDim),
    );

    table = CustomPaint(
      foregroundPainter: MyPainter(longPressPosition, currentPosition),
      child: table,
    );

    // Gesture detector for long press (easy multi-select)
    table = GestureDetector(
      child: table,
      onLongPressStart: (details){
        setState(() {
          longPressDown = true;
          longPressPosition = details.localPosition;
        });

      },
      onLongPressMoveUpdate: (details){
        setState(() {
          currentPosition = details.localPosition;
        });
      },
      onLongPressEnd: (details){
        setState(() {
          longPressDown = false;
          longPressPosition = null;
          currentPosition = null;
        });

      },);

    return table;

  }

}

class SingleGridSquare extends StatefulWidget {

  SingleGridSquare(this.parentState, this.i, this.j, this.defaultDim, this.c, this.clueNumber, this.clueNumberText)
  {
    isEmpty = c == '';
  }

  final _CrosswordGridEditorState parentState;
  final int i;
  final int j;
  final double defaultDim;
  final String c;
  final int clueNumber;
  final String clueNumberText;
  bool isEmpty;

  @override
  _SingleGridSquareState createState() => _SingleGridSquareState();
}

class _SingleGridSquareState extends State<SingleGridSquare> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 1, duration: Duration(milliseconds: 500));
    _controller.addListener(() {
      setState(() {

    });});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget square;

  void toggleSquareAtPosition() {
    int i = widget.i;
    int j = widget.j;

    if(widget.isEmpty){
      _controller.forward(from: 0.7);
    }

    setState(() {
      widget.parentState.toggleSquareAtPosition(i, j);
    });
  }

  @override
  Widget build(BuildContext context) {

    int i = widget.i;
    int j = widget.j;
    String c = widget.c;
    int clueNumber = widget.clueNumber;
    String clueNumberText = widget.clueNumberText;
    bool isEmpty = widget.isEmpty;

    square = new Container(
        child: Text(clueNumberText + c),
        width: widget.defaultDim,
        height: widget.defaultDim,
        decoration: BoxDecoration(border: Border.all(), color: isEmpty ? Colors.black : Colors.white)
    );

    square = GestureDetector(
      child: square,
      onTap: () {
        toggleSquareAtPosition();
      },
    );

    square = Transform.scale(
            child: square,
            scale: _controller.value);

    if(widget.parentState.longPressDown){
      square = Draggable(
        feedback: Container(width: 20, height: 20, color: Colors.amber),
        child: square,
      );
    }


    return square;
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
      ..color = Colors.blueAccent
      ..strokeWidth = 1;
    canvas.drawLine(p1, p2, paint);
    print('PAINTING: ' + doubleTapPosition.toString() + ' TO ' + currentPosition.toString());
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}