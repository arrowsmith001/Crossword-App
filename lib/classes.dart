class CrosswordPuzzle{

  static const String DEFAULT_PUZZLE_NAME = 'Crossword Puzzle';

  CrosswordPuzzle(){
    handler = new CrosswordPuzzleHandler(this);
  }

  CrosswordPuzzleHandler handler;

  String title = CrosswordPuzzle.DEFAULT_PUZZLE_NAME;
  int rows;
  int cols;

  // Key is linear position in grid (reading left-to-right, top-to-bottom, beginning at 0), value is the character code at that position
  Map<int, int> letterMap = {};

  // Key is linear position in grid (reading left-to-right, top-to-bottom, beginning at 0), value is a clue at that position
  Map<int, ClueSet> clueMap = {};

}

class CrosswordPuzzleHandler {

  List<Clue> acrossClues = [];
  List<Clue> downClues = [];

  CrosswordPuzzleHandler(this.puzzle);

  final CrosswordPuzzle puzzle;

  String getCharAtPosition(int i, int j){
    if(i < 0 || j < 0) return '';
    if(puzzle.rows < i+1 || puzzle.cols < j+1) return '';

    int linearPosition = _getLinearPosition(i, j);
    if(!puzzle.letterMap.containsKey(linearPosition)) return '';
    int charCode = puzzle.letterMap[linearPosition];
    String char = String.fromCharCode(charCode);
    return char;
  }

  void addCharAtPosition(String c, int i, int j) {

    if(i < 0 || j < 0) return;
    if(puzzle.rows < i+1) puzzle.rows = i;
    if(puzzle.cols < j+1) puzzle.cols = j;

    int linearPosition = _getLinearPosition(i, j);

    if(c == ''){
      if(puzzle.letterMap.containsKey(linearPosition)) puzzle.letterMap.remove(linearPosition);
    }
    else{
      int charCode = c.codeUnitAt(0);
      if(!puzzle.letterMap.containsKey(linearPosition)) puzzle.letterMap.addAll({linearPosition: charCode});
      else puzzle.letterMap[linearPosition] = charCode;
    }

    _updateClueMap(c, i, j);
  }

  int _getLinearPosition(int i, int j) => i*puzzle.cols + j;

  static bool validatePuzzle(CrosswordPuzzle puzzle) {
    return true;
    throw InvalidCrosswordPuzzleException("Error message");
  }


  String _getCharAtRelativePosition(int i, int j, GridDirection direction) {
    switch(direction){

      case GridDirection.up:
        return getCharAtPosition(i-1, j);
        break;
      case GridDirection.down:
        return getCharAtPosition(i+1, j);
        break;
      case GridDirection.left:
        return getCharAtPosition(i, j-1);
        break;
      case GridDirection.right:
        return getCharAtPosition(i, j+1);
        break;
      default: return '';
    }
  }

  int getClueNumberAtPosition(int i, int j) {
    ClueSet clueSet = puzzle.clueMap[_getLinearPosition(i, j)];
    if(clueSet == null) return null;
    return clueSet.clueNumber;
  }

  void setRows(int rows) {
    puzzle.rows = rows;
  }

  void setCols(int cols) {
    puzzle.cols = cols;
  }

  int getRows() => this.puzzle.rows;

  int getCols() => this.puzzle.cols;

  // Requires optimisation
  void _updateClueMap(String cChanged, int iChanged, int jChanged) {

    puzzle.clueMap.clear();
    acrossClues.clear();
    downClues.clear();

    int linearPosition = -1;
    int currentClueNumber = 1;

    for(int i = 0; i<puzzle.rows; i++){

      for(int j = 0; j<puzzle.cols; j++){

        linearPosition++;

        String currentChar = getCharAtPosition(i, j);

        if(currentChar == '') continue;

        ClueSet currentClueSet = puzzle.clueMap[linearPosition];

        // Check for across clues
        String leftChar = _getCharAtRelativePosition(i, j, GridDirection.left);
        String rightChar = _getCharAtRelativePosition(i, j, GridDirection.right);

        if(leftChar == '' && rightChar != ''){

          // There exists an across clue here
          int length = 1;
          int offset = 0;

          // Scan rightward to determine word length
          while(rightChar != ''){
            length++;
            offset++;
            rightChar = _getCharAtRelativePosition(i, j+offset, GridDirection.right);
          }

          // Add an across clue
          Clue newClue = new Clue(currentClueNumber, '', WordDirection.across, length);
          acrossClues.add(newClue);

          if(currentClueSet == null) {
            currentClueSet = new ClueSet(currentClueNumber, acrossClue : newClue);
          }else{
            currentClueSet.acrossClue = newClue;
          }

          puzzle.clueMap.addAll({linearPosition : currentClueSet});
        }

        // Check for down clues
        String upChar = _getCharAtRelativePosition(i, j, GridDirection.up);
        String downChar = _getCharAtRelativePosition(i, j, GridDirection.down);

        if(upChar == '' && downChar != ''){

          // There exists a down clue here
          int length = 1;
          int offset = 0;

          // Scan rightward to determine word length
          while(downChar != ''){
            length++;
            offset++;
            downChar = _getCharAtRelativePosition(i+offset, j, GridDirection.down);
          }

          // Add a down clue
          Clue newClue = new Clue(currentClueNumber, '', WordDirection.down, length);
          downClues.add(newClue);

          if(currentClueSet == null) {
            currentClueSet = new ClueSet(currentClueNumber, downClue : newClue);
          }else{
            currentClueSet.downClue = newClue;
          }

          puzzle.clueMap.addAll({linearPosition : currentClueSet});
        }

        if(currentClueSet != null) currentClueNumber++;

      }
    }

  }

  int getNumberOfAcrossClues() => this.acrossClues.length;
  int getNumberOfDownClues() => this.downClues.length;

  Clue getAcrossClue(int i) => acrossClues[i];
  Clue getDownClue(int i) => downClues[i];

  List<Clue> getAcrossClues() => acrossClues;

  List<Clue> getDownClues() => downClues;
}

class InvalidCrosswordPuzzleException {
  InvalidCrosswordPuzzleException(String error);
}

class CrosswordPuzzleConcreteBuilder implements CrosswordPuzzleBuilder{

  CrosswordPuzzleHandler handler = new CrosswordPuzzleHandler(new CrosswordPuzzle());

  CrosswordPuzzleConcreteBuilder(int initialRows, int initialCols){
    handler.setRows(initialRows);
    handler.setCols(initialCols);
  }

  void addWhiteSquareAtPosition(int i, int j){
    String currentChar = handler.getCharAtPosition(i, j);
    if(currentChar == '') handler.addCharAtPosition(' ', i, j);
  }

  void addBlackSquareAtPosition(int i, int j){
    String currentChar = handler.getCharAtPosition(i, j);
    if(currentChar != '') handler.addCharAtPosition('', i, j);
  }

  void toggleSquareAtPosition(int i, int j) {
    if(handler.getCharAtPosition(i, j) == '') addWhiteSquareAtPosition(i, j);
    else addBlackSquareAtPosition(i, j);
  }

  void addCharacterAtPosition(String c, int i, int j){
    String currentChar = handler.getCharAtPosition(i, j);
    if(currentChar != '') handler.addCharAtPosition(c, i, j);
  }

  CrosswordPuzzle getPuzzle(){
    return handler.puzzle;
  }

  static CrosswordPuzzle getSamplePuzzle(){

  }

  int getColumns() => handler.getCols();

  int getRows() => handler.getRows();

  CrosswordPuzzleHandler getHandler() => handler;


}


class ClueSet{
  ClueSet(this.clueNumber, {this.acrossClue, this.downClue});

  int clueNumber;
  Clue acrossClue;
  Clue downClue;
}

class Clue{
  Clue(this.clueNumber, this.description, this.direction, this.length);

  int clueNumber;
  String description;
  WordDirection direction;
  int length;

}

enum WordDirection{
  across, down
}
enum GridDirection{
  up, down, left, right
}

abstract class CrosswordPuzzleBuilder {

  void addWhiteSquareAtPosition(int i, int j);

  void addBlackSquareAtPosition(int i, int j);

  void addCharacterAtPosition(String c, int i, int j);

  int getRows();

  int getColumns();

  CrosswordPuzzle getPuzzle();

  void toggleSquareAtPosition(int i, int j);

  CrosswordPuzzleHandler getHandler();
}