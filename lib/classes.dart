class CrosswordPuzzle{

  static const String DEFAULT_PUZZLE_NAME = 'Crossword Puzzle';

  String title = CrosswordPuzzle.DEFAULT_PUZZLE_NAME;
  int rows;
  int cols;

  // Key is linear position in grid (reading left-to-right, top-to-bottom, beginning at 0), value is the character code at that position
  Map<int, int> letterMap = {};

  // Key is linear position in grid (reading left-to-right, top-to-bottom, beginning at 0), value is a clue at that position
  Map<int, ClueSet> clueMap = {};

  String getCharAtPosition(int i, int j){
    if(i < 0 || j < 0) return '';
    if(rows < i+1 || cols < j+1) return '';

    int linearPosition = _getLinearPosition(i, j);
    if(!letterMap.containsKey(linearPosition)) return '';
    int charCode = letterMap[linearPosition];
    String char = String.fromCharCode(charCode);
    return char;
  }

  void addCharAtPosition(String c, int i, int j) {

    if(i < 0 || j < 0) return;
    if(rows < i+1) rows = i;
    if(cols < j+1) cols = j;

    int linearPosition = _getLinearPosition(i, j);

    if(c == ''){
      if(letterMap.containsKey(linearPosition)) letterMap.remove(linearPosition);
    }
    else{
      int charCode = c.codeUnitAt(0);
      if(!letterMap.containsKey(linearPosition)) letterMap.addAll({linearPosition: charCode});
      else letterMap[linearPosition] = charCode;
    }

    _updateClueMap();
  }

  int _getLinearPosition(int i, int j) => i*cols + j;

  static bool validatePuzzle(CrosswordPuzzle puzzle) {
    return true;
    throw InvalidCrosswordPuzzleException("Error message");
  }

  void _updateClueMap() {

    clueMap.clear();

    int linearPosition = -1;
    int currentClueNumber = 1;

    for(int i = 0; i<rows; i++){

      for(int j = 0; j<cols; j++){

        linearPosition++;

        String currentChar = getCharAtPosition(i, j);

        if(currentChar == '') continue;

        // Check for across clues
        String leftChar = _getCharAtRelativePosition(i, j, GridDirection.left);
        String rightChar = _getCharAtRelativePosition(i, j, GridDirection.right);

        if(leftChar == '' && rightChar != ''){

          // There exists an across clue here
          int length = 2;
          int offset = 0;

          // Scan rightward to determine word length
          while(rightChar != ''){
            length++;
            offset++;
            rightChar = _getCharAtRelativePosition(i, j+offset, GridDirection.right);
          }

          // Add an across clue
          Clue newClue = new Clue('', WordDirection.across, length);
          ClueSet currentClueSet = clueMap[linearPosition];

          if(currentClueSet == null) {
            currentClueSet = new ClueSet(currentClueNumber, acrossClue : newClue);
          }else{
            currentClueSet.acrossClue = newClue;
          }

          clueMap.addAll({linearPosition : currentClueSet});
        }

        // Check for down clues
        String upChar = _getCharAtRelativePosition(i, j, GridDirection.up);
        String downChar = _getCharAtRelativePosition(i, j, GridDirection.down);

        if(upChar == '' && downChar != ''){
          // There exists a down clue here
          int length = 2;
          int offset = 0;

          // Scan rightward to determine word length
          while(downChar != ''){
            length++;
            offset++;
            downChar = _getCharAtRelativePosition(i+offset, j, GridDirection.down);
          }

          // Add a down clue
          Clue newClue = new Clue('', WordDirection.down, length);
          ClueSet currentClueSet = clueMap[linearPosition];

          if(currentClueSet == null) {
            currentClueSet = new ClueSet(currentClueNumber, downClue : newClue);
          }else{
            currentClueSet.downClue = newClue;
          }

          clueMap.addAll({linearPosition : currentClueSet});
        }

        ClueSet currentClueSet = clueMap[linearPosition];
        if(currentClueSet != null) currentClueNumber++;

      }
    }

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
    ClueSet clueSet = clueMap[_getLinearPosition(i, j)];
    if(clueSet == null) return null;
    return clueSet.clueNumber;
  }

}

class InvalidCrosswordPuzzleException {
  InvalidCrosswordPuzzleException(String error);
}

class ClueSet{
  ClueSet(this.clueNumber, {this.acrossClue, this.downClue});

  int clueNumber;
  Clue acrossClue;
  Clue downClue;
}

class Clue{
  Clue(this.description, this.direction, this.length);
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

class CrosswordPuzzleConcreteBuilder implements CrosswordPuzzleBuilder{

  CrosswordPuzzle puzzle = new CrosswordPuzzle();

  CrosswordPuzzleConcreteBuilder(int initialRows, int initialCols){
    puzzle.rows = initialRows;
    puzzle.cols = initialCols;
  }

  void addWhiteSquareAtPosition(int i, int j){
    String currentChar = puzzle.getCharAtPosition(i, j);
    if(currentChar == '') puzzle.addCharAtPosition(' ', i, j);
  }

  void addBlackSquareAtPosition(int i, int j){
    String currentChar = puzzle.getCharAtPosition(i, j);
    if(currentChar != '') puzzle.addCharAtPosition('', i, j);
  }

  void addCharacterAtPosition(String c, int i, int j){
    String currentChar = puzzle.getCharAtPosition(i, j);
    if(currentChar != '') puzzle.addCharAtPosition(c, i, j);
  }

  CrosswordPuzzle getPuzzle(){
    bool isValid = CrosswordPuzzle.validatePuzzle(puzzle);
    return puzzle;
  }

  static CrosswordPuzzle getSamplePuzzle(){

  }

  int getColumns() => puzzle.cols;

  int getRows() => puzzle.rows;

  void toggleSquareAtPosition(int i, int j) {
    if(puzzle.getCharAtPosition(i, j) == '') addWhiteSquareAtPosition(i, j);
    else addBlackSquareAtPosition(i, j);
  }

}

abstract class CrosswordPuzzleBuilder {

  void addWhiteSquareAtPosition(int i, int j);

  void addBlackSquareAtPosition(int i, int j);

  void addCharacterAtPosition(String c, int i, int j);

  int getRows();

  int getColumns();

  CrosswordPuzzle getPuzzle();

  void toggleSquareAtPosition(int i, int j);
}