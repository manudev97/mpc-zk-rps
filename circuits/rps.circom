// Circuit was adapted from one received from Prof Albert Rubio
pragma circom 2.0.0;
include "../node_modules/circomlib/circuits/comparators.circom";

template RockPaperScissors2() {
  signal input player1;
  signal input player2;

  // 0 - draw, 1 - player1, 2 - player2
  signal output winner;

  // we add constraints stating that the input player1 can only be 2, 3, 5
  signal p1check;
  p1check <== (player1 - 2) * (player1 - 3);
  p1check * (player1 - 5) === 0;

  // we add constraints stating that the input player2 can only be 2, 3, 5
  signal p2check;
  p2check <== (player2 - 2) * (player2 - 3);
  p2check * (player2 - 5) === 0;

  var rock = 2;
  var paper = 3;
  var scissors = 5;

  var rockScissors = rock * scissors;
  
  signal player1x2;
  player1x2 <== player1 * player2;

  component isRockScissorsComp = IsZero();
  
  isRockScissorsComp.in <== player1x2-rockScissors;

  // this signal indicates if we are in the case RockScissors or not
  signal isRockScissors;
  isRockScissors <== isRockScissorsComp.out;
  
  component isDrawComp = IsEqual();
  
  isDrawComp.in[0] <== player1;
  isDrawComp.in[1] <== player2;

  signal isDraw;
  isDraw <== isDrawComp.out;

  component isP1LessComp = LessThan(3); //only tree bits needed for 2,3,5
  isP1LessComp.in[0] <== player1;
  isP1LessComp.in[1] <== player2;

  // this signal indicates if the value of player1 is strictly smaller than player2
  signal isP1Less;
  isP1Less <== isP1LessComp.out;

  // this signal provides the correct winner assuming we are not in the Draw case
  signal winnerNoDraw;
  // First we give the way to compute the value of the signal
  var aux;
  if (isRockScissors) {
      aux = isP1Less ? 1 : 2;
  } else {
      aux = isP1Less ? 2 : 1;
  }
  winnerNoDraw <-- aux;
  
  // Second we introduce the constraints that describe the computation above
  isRockScissors * (winnerNoDraw - (2 - isP1Less)) === 0;
  (1 - isRockScissors) * (winnerNoDraw - (isP1Less + 1)) === 0;

  //First we describe how to compute the result in all cases
  var res;
  if (isDraw) {
     res = 0;
  } else {
    res = winnerNoDraw;
  }
  winner <-- res;
  //Second, we introduce the constraints that describe the computation above  
  isDraw * winner === 0; // if isDraw is different from 0 then winner is 0
  (isDraw - 1) * (winner - winnerNoDraw) === 0;

}

component main = RockPaperScissors2();