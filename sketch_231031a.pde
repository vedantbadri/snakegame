int nCols = 30;
int nRows = 30;

float columnWidth;
float rowHeight;

// Reference to snakeGame object
SnakeGame snakeGame;

// initialize key input
char nextInput = '\0';

// flag variable for game ending
boolean gameOver = false;

// Menu variables
int menuState = 0; // 0 - Start menu, 1 - In-game, 2 - Game over menu
String[] players = { "Player 1", "Player 2", "Player 3" };
int[] scores = { 0, 0, 0 };
int currentPlayer = 0;

// Name input
boolean nameInput = true; // Initially, set to true
String playerName = "";

void setup() {
  size(700, 700);
  columnWidth = width / nCols;
  rowHeight = height / nRows;
  frameRate(15);
  ellipseMode(CORNER);
  snakeGame = new SnakeGame();
  menuState = 0;
}

void draw() {
  if (nameInput) {
    displayNameInput();
  } else if (menuState == 0) {
    displayStartMenu();
  } else if (menuState == 1) {
    // Game screen
    if (!gameOver) {
      background(180, 195, 20);
      snakeGame.submitMove(nextInput);
      snakeGame.update();
      snakeGame.display();
      if (snakeGame.snake.checkCollision()) {
        gameOver = true;
        menuState = 2; // Show game over menu
        snakeGame.gameOver();
      }
      nextInput = '\0';
      text("Press Shift-key to reverse", width - 180, height - 10);
    } else {
      menuState = 2; // Show game over menu
    }
  } else if (menuState == 2) {
    displayGameOverMenu();
  }
}

void keyPressed() {
  if (nameInput) {
    if (key == 'P' || key == 'p') {
      nameInput = false; // Transition to the game
    } else if (key == ENTER) {
      nameInput = false; // Transition to the game
    } else if (key == BACKSPACE) {
      if (playerName.length() > 0) {
        playerName = playerName.substring(0, playerName.length() - 1);
      }
    } else if (key != CODED) {
      playerName += key;
    }
  } else if (menuState == 0) {
    // Start menu key handling
    if (keyCode == ENTER) {
      menuState = 1; // Transition to the game
    } else if (key == 'q' || key == 'Q') {
      exit();
    }
  } else if (menuState == 1) {
    // In-game key handling
    if (key == CODED) {
      switch (keyCode) {
        case UP:
          nextInput = 'U'; // Go upwards
          break;
        case DOWN:
          nextInput = 'D'; // Go downwards
          break;
        case LEFT:
          nextInput = 'L'; // Go left
          break;
        case RIGHT:
          nextInput = 'R'; // Go right
          break;
        case SHIFT:
          nextInput = 'S'; // Reverse
          break;
      }
    } else if (key == ' ') {
      // Start a new game
      scores[currentPlayer] = snakeGame.score;
      currentPlayer = (currentPlayer + 1) % players.length;
      snakeGame.resetGame();
      gameOver = false;
      menuState = 1;
    }
  } else if (menuState == 2) {
    // Game over menu key handling
    if (key == ' ') {
      // Start a new game
      scores[currentPlayer] = snakeGame.score;
      currentPlayer = (currentPlayer + 1) % players.length;
      snakeGame.resetGame();
      gameOver = false;
      menuState = 1;
    } else if (key == 'q' || key == 'Q') {
      exit();
    }
  }
}

void displayStartMenu() {
  background(0);
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Snake Game", width / 2, height / 3);
  textSize(16);
  text("Press Enter to Start", width / 2, height / 2);
  text("Press Q to Quit", width / 2, height / 2 + 30);
}

void displayGameOverMenu() {
  background(0);
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Game Over, " + playerName, width / 2, height / 3);
  text("Score: " + snakeGame.score, width / 2, height / 2);
  text("Press Space to Play Again", width / 2, height / 2 + 30);
  text("Press Q to Quit", width / 2, height / 2 + 60);
  text("Current High Score: " + getMaxScore(), width / 2, height / 2 + 90);
}

void displayNameInput() {
  background(0);
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Enter Your Name:", width / 2, height / 3);
  textSize(16);
  text(playerName, width / 2, height / 2);
  text("Press P to Start", width / 2, height / 2 + 30);
}

int getMaxScore() {
  int maxScore = scores[0];
  for (int i = 1; i < players.length; i++) {
    if (scores[i] > maxScore) {
      maxScore = scores[i];
    }
  }
  return maxScore;
}

class SnakeGame {
  LinkedList snake;
  int goalColumn;
  int goalRow;
  int score = 0;

  SnakeGame() {
    resetGame();
  }

  void resetGame() {
    createSnake(8);
    score = 0;
    resetGoal();
  }

  void createSnake(int n) {
    snake = new LinkedList();
    if (n < 1) {
      return;
    }
    snake.addFront(new Node(nRows / 2, nCols / 2, 0, -1));
    for (int i = 0; i < n - 1; i++) {
      snake.addTailNode();
    }
  }

  void resetGoal() {
    goalColumn = floor(random(nCols));
    goalRow = floor(random(nRows));
  }

  void gameOver() {
    textAlign(CENTER);
    textSize(20);
    text("Game Over", width / 2, height / 2 - 20);
    textSize(18);
    text("Score: " + score, width / 2, height / 2);
    textSize(14);
    text("Press Space Bar to Play Again", width / 2, height / 2 + 15);
    text("Press Q to Quit", width / 2, height / 2 + 35);
  }

  boolean checkGoal(int column, int row) {
    return column == goalColumn && row == goalRow;
  }

  void submitMove(char move) {
    switch (move) {
      case 'U':
        snake.setDirection(0, -1);
        break;
      case 'D':
        snake.setDirection(0, 1);
        break;
      case 'L':
        snake.setDirection(-1, 0);
        break;
      case 'R':
        snake.setDirection(1, 0);
        break;
      case 'S':
        snake.reverse();
        snake.propagateDirections();
        break;
    }
  }

  void display() {
  snake.display();
  stroke(0);
  strokeWeight(3);
  noFill();
  ellipse(goalColumn * columnWidth, goalRow * rowHeight, columnWidth, rowHeight);

  // Display score within the game canvas
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("Score: " + score, 20, 20);
  
  displayOverlay();
}


  void update() {
    snake.updatePositions();
    snake.propagateDirections();
    if (checkGoal(snake.currentHead().column, snake.currentHead().row)) {
      score++;
      resetGoal();
      snake.addTailNode();
    }
  }

  void displayOverlay() {
    stroke(180, 195, 20);
    strokeWeight(0.5);
    float spacing = 3;
    for (float i = 0; i < width; i += spacing) {
      line(i, 0, i, height);
    }
    for (float i = 0; i < height; i += spacing) {
      line(0, i, width, i);
    }
  }
}

class LinkedList {
  int size = 0;
  Node head;
  Node end;
  boolean reversed = false;

  void addFront(Node node) {
    node.next = head;
    if (size == 0) {
      end = node;
    } else {
      head.prev = node;
    }
    head = node;
    size++;
  }

  void addEnd(Node node) {
    if (size == 0) {
      head = node;
      end = node;
      return;
    }
    end.next = node;
    node.prev = end;
    end = node;
    size++;
  }

  void addTailNode() {
    if (!reversed && end != null) {
      addEnd(new Node(end.column - end.xDirection, end.row - end.yDirection, end.xDirection, end.yDirection));
    } else if (head != null) {
      addFront(new Node(head.column + head.xDirection, head.row + head.yDirection, head.xDirection, head.yDirection));
    }
  }

  void updatePositions() {
    Node current = head;
    while (current != null) {
      current.updatePosition(reversed);
      current = current.next;
    }
  }

  void propagateDirections() {
    if (!reversed) {
      Node current = end;
      while (current != null) {
        current.updateDirection(reversed);
        current = current.prev;
      }
    } else {
      Node current = head;
      while (current != null) {
        current.updateDirection(reversed);
        current = current.next;
      }
    }
  }

  Node currentHead() {
    return reversed ? end : head;
  }

  void setDirection(int xDirection, int yDirection) {
    Node currentHead = this.currentHead();
    if (reversed) {
      xDirection = -xDirection;
      yDirection = -yDirection;
    }
    if (currentHead.xDirection != -xDirection || currentHead.yDirection != -yDirection) {
      currentHead.xDirection = xDirection;
      currentHead.yDirection = yDirection;
    }
  }

  boolean checkCollision() {
    Node currentHead = this.currentHead();
    Node current = reversed ? head : end;
    while (current != currentHead) {
      if (current.row == currentHead.row && current.column == currentHead.column) {
        return true;
      }
      if (!reversed) {
        current = current.prev;
      } else {
        current = current.next;
      }
    }
    return false;
  }

  void reverse() {
    reversed = !reversed;
  }

  void display() {
    Node current = head;
    while (current != null) {
      current.display();
      current = current.next;
    }
  }

  String toString() {
    if (size == 0) {
      return "";
    }
    String listString = head.toString();
    Node current = head.next;
    while (current != null) {
      listString += ", " + current.toString();
      current = current.next;
    }
    return listString;
  }
}

class Node {
  Node prev, next;
  int column, row;
  int xDirection, yDirection;

  Node(int column, int row, int xDirection, int yDirection) {
    this.column = column;
    this.row = row;
    this.xDirection = xDirection;
    this.yDirection = yDirection;
  }

  void display() {
    fill(0);
    noStroke();
    rect(column * columnWidth, row * rowHeight, columnWidth, rowHeight);
  }

  void updatePosition(boolean reversed) {
    int direction = reversed ? -1 : 1;
    column = wrap(column + direction * xDirection, nCols);
    row = wrap(row + direction * yDirection, nRows);
  }

  void updateDirection(boolean reversed) {
    if (!reversed && prev != null) {
      xDirection = prev.xDirection;
      yDirection = prev.yDirection;
    } else if (next != null) {
      xDirection = next.xDirection;
      yDirection = next.yDirection;
    }
  }

  int wrap(int n, int max) {
    n %= max;
    if (n < 0) {
      n = max + n;
    }
    return n;
  }

  String toString() {
    return "(" + column + ", " + row + ")";
  }
}
