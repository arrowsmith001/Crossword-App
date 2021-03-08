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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(

        child: InteractiveViewer(
          minScale: 0.01,
          maxScale: 200,
          constrained: false,
          child: CrosswordGrid(columns: 9, rows: 5),

        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class CrosswordGrid extends StatelessWidget {

  CrosswordGrid({this.columns, this.rows});

  final int columns;
  final int rows;
  final double dim = 100;

  @override
  Widget build(BuildContext context) {

    List<TableRow> crosswordGridRows = [];

    for(int i = 0; i<rows; i++){

      List<Widget> rowContents = [];

      for(int j = 0; j<columns; j++){
        rowContents.add(new Container(width: dim, height: dim, decoration: BoxDecoration(border: Border.all()),));
      }

      TableRow crosswordGridRow = new TableRow(children: rowContents);
      crosswordGridRows.add(crosswordGridRow);

    }

    return Table(
      children: crosswordGridRows,
      defaultColumnWidth: FixedColumnWidth(dim),
    );
  }
}