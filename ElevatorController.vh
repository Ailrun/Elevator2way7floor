`timescale 1ns / 1ps

`include "Elevator.vh"

module ElevatorController#(parameter CLK_PER_OPEN = 100000000, CLK_PER_MOVE = 200000000, CLK_PER_HOLD = 2000000)
   (
    input         clk,
    input         reset,
    input [11:0]  realFloorButton,
    input [9:1]   realInternalButton1,
    input [9:1]   realInternalButton2,
    output [11:0] nextRealFloorButton,
    output [9:1]  nextRealInternalButton1,
    output [9:1]  nextRealInternalButton2,
    output [2:0]  nextFloor1,
    output [2:0]  nextFloor2,
    output [1:0]  nextDirection1,
    output [1:0]  nextDirection2,
    output        doorState1,
    output        doorState2.
    output        move1,
    output        move2
    );

   localparam ON = 1'b1, OFF = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     OPEN = 1'b1, CLOSE = 1'b0,
     INIT = 2'b00, COUNT_MAX = 2'b11;

   reg [13:0]     unusedFloorButton;
   reg [13:0]     floorButton1;
   reg [13:0]     floorButton2;
   reg [9:1]      internalButton1;
   reg [9:1]      internalButton2;

   wire [13:0]    newFloorButton = {1'b0, realFloorButton, 1'b0};
   wire [13:0]    nextFloorButton1;
   wire [13:0]    nextFloorButton2;
   wire [9:1]     nextInternalButton1;
   wire [9:1]     nextInternalButton2;
   wire [13:0]    allFloorButton = nextFloorButton1 | nextFloorButton2 |
                  newFloorButton | unusedFloorButton

   reg [1:0]      counter;

   integer        i;

   Elevator#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   ele1(clk, reset, floorButton1, internalButton1,
        nextFloor1, nextDirection1, nextFloorButton1, nextInternalButton1,
        doorState1, move1);
   Elevator#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   ele2(clk, reset, floorButton2, internalButton2,
        nextFloor2, nextDirection2, nextFloorButton2, nextInternalButton2,
        doorState2, move2);

   always @(posedge clk)
     begin
        if (reset == 1)
          begin
             unusedFloorButton <= 14'0;
             floorButton1 <= 14'b0;
             floorButton2 <= 14'b0;
             internalButton1 <= 9'b0;
             internalButton2 <= 9'b0;
             counter <= INIT;
          end
        else if (counter == INIT)
          begin
             internalButton1 <= nextInternalButton1 | realInternalButton1;
             internalButton2 <= nextInternalButton2 | realInternalButton2;
             giveFloorButton(1,
                             nextFloorButton1[1:0],
                             nextFloorButton2[1:0],
                             unusedFloorButton[1:0],
                             allFloorButton[1:0],
                             nextFloor1, nextFloor2, move1, move2,
                             floorButton1[1:0], floorButton2[1:0],
                             unusedFloorButton[1:0]);
             giveFloorButton(2,
                             nextFloorButton1[3:2],
                             nextFloorButton2[3:2],
                             unusedFloorButton[3:2],
                             allFloorButton[3:2],
                             nextFloor1, nextFloor2, move1, move2,
                             floorButton1[3:2], floorButton2[3:2],
                             unusedFloorButton[3:2]);
             giveFloorButton(3,
                             nextFloorButton1[5:4],
                             nextFloorButton2[5:4],
                             unusedFloorButton[5:4],
                             allFloorButton[5:4],
                             nextFloor1, nextFloor2, move1, move2,
                             floorButton1[5:4], floorButton2[5:4],
                             unusedFloorButton[5:4]);
             giveFloorButton(4,
                             nextFloorButton1[7:6],
                             nextFloorButton2[7:6],
                             unusedFloorButton[7:6],
                             allFloorButton[7:6],
                             nextFloor1, nextFloor2, move1, move2,
                             floorButton1[7:6], floorButton2[7:6],
                             unusedFloorButton[7:6]);
             giveFloorButton(5,
                             nextFloorButton1[9:8],
                             nextFloorButton2[9:8],
                             unusedFloorButton[9:8],
                             allFloorButton[9:8],
                             nextFloor1, nextFloor2, move1, move2,
                             floorButton1[9:8], floorButton2[9:8],
                             unusedFloorButton[9:8]);
             giveFloorButton(6,
                             nextFloorButton1[11:10],
                             nextFloorButton2[11:10],
                             unusedFloorButton[11:10],
                             allFloorButton[11:10],
                             nextFloor1, nextFloor2, move1, move2,
                             floorButton1[11:10], floorButton2[11:10],
                             unusedFloorButton[11:10]);
             giveFloorButton(7,
                             nextFloorButton1[13:12],
                             nextFloorButton2[13:12],
                             unusedFloorButton[13:12],
                             allFloorButton[13:12],
                             nextFloor1, nextFloor2, move1, move2,
                             floorButton1[13:12], floorButton2[13:12],
                             unusedFloorButton[13:12]);
             counter <= 3;
          end // if (counter == INIT)
        else
          counter <= counter - 1;
     end // always @ (posedge clk)

   function isIn;
      input [1:0] currentDirection;
      input [1:0] currentFloorButton;
      begin
         case (currentDirection)
           STOP   : isIn = (currentFloorButton == STOP);
           UP     : isIn = (currentFloorButton == UP
                            || currentFloorButton == UPDOWN);
           DOWN   : isIn = (currentFloorButton == DOWN
                            || currentFloorButton == UPDOWN);
           UPDOWN : begin
              isIn = 1'b0
              $display("ERROR in Door!");
           end
         endcase // case (currentDirection)
      end
   endfunction // isIn

   /*
    There are some cases the elevators get buttons.
    1. Both Ele. are in STOP state, and this one is closer.
    2. The other Ele. is in UP state and higher then button Floor, and
       this one is in STOP state.
    3. The other Ele. is in DOWN state and target button is UP button.
       Furthermore, this one is in STOP state
    4. The other Ele. is in UP state and is farther than this one, which is in STOP state,
       and target button is UP button.
    5. The other Ele is in DOWN, counterwise of 2.
    6. Counterwise of 3.
    7. Counterwise of 4.
    8. Both Ele. are in moving state, and this one is in button Floor.

    There are also some cases the elevator lose buttons.
    1. The other Ele. is in button Floor, and have direction including 'the button',
       except button is UP and this Ele. is Ele.1 in button Floor,
       or button is DOWN and this Ele. is Ele.2 in button Floor.
      (Ele.1 has priority of UP button, and Ele.2 has priority of DOWN button)

    Except these, buttons are conserved.
    */
   task giveFloorButton;
      input [2:0] buttonF;
      input [1:0] nextFB2B1;
      input [1:0] nextFB2B2;
      input [1:0] unusedFB2BI;
-      input [1:0] allFB;
      input [2:0] nextF1;
      input [2:0] nextF2;
      input [1:0] move1;
      input [1:0] move2;
      output reg [1:0] fB2B1;
      output reg [1:0] fB2B2;
      output reg [1:0] unusedFB2BO;
      begin
         fB2B1[1] <= (nextFB2B1[1] & ~(nextF2 == buttonF & nextF1 != buttonF &
                                       (move2 == STOP | move2[1]))) |
                     (move1 == UP & allFB[1] & nextF1 == buttonF) |
                     (move1 == STOP & unusedFB2BI[1] &
                      (((move2 == STOP | (move2 == UP | nextF2 > buttonF)) &
                        isCloser(buttonF, nextF1, nextF2)) |
                       (move2 == DOWN)));
         fB2B1[0] <= ((nextFB2B1[0] | (move1 == DOWN & allFB[0] & nextF1 == buttonF)) &
                      ~(nextF2 == buttonF &
                        (move2 == STOP | move2[0]))) |
                     (move1 == STOP & unusedFB2BI[0] &
                      (((move2 == STOP | (move2 == DOWN | nextF2 < buttonF)) &
                        isCloser(buttonF, nextF1, nextF2)) |
                       (move2 == UP)));
         fB2B2[1] <= ((nextFB2B2[1] | (move2 == UP & allFB[1] & nextF2 == buttonF)) &
                      ~(nextF1 == buttonF &
                        (move1 == STOP | move1[1]))) |
                     (move2 == STOP & unusedFB2BI[1] &
                      (((move1 == STOP | (move1 == DOWN | nextF1 > buttonF)) &
                        isCloser(buttonF, nextF2, nextF1)) |
                       (move2 == DOWN)));
         fB2B1[0] <= (nextFB2B2[0] & ~(nextF1 == buttonF & nextF2 != buttonF &
                                       (move1 == STOP | move1[0]))) |
                     (move2 == DOWN & allFB[0] & nextF2 == buttonF) |
                     (move2 == STOP & unusedFB2BI[0] &
                      (((move1 == STOP | (move1 == DOWN | nextF1 < buttonF)) &
                        isCloser(buttonF, nextF2, nextF1)) |
                       (move1 == UP)));
         unusedFB2BO[1] <= (allFB[1] & ~((move1 == STOP & (isCloser(buttonF, nextF1, nextF2) |
                                                           move2 == DOWN |
                                                           (move2 == UP & nextF2 > buttonF))) |
                                         (move2 == STOP & (isCloser(buttonF, nextF2, nextF1) |
                                                           move1 == DOWN |
                                                           (move1 == UP & nextF1 > buttonF)))));
         unusedFB2BO[0] <= (allFB[1] & ~((move1 == STOP & (isCloser(buttonF, nextF1, nextF2) |
                                                          move2 == DOWN |
                                                          (move2 == UP & nextF2 > buttonF))) |
                                        (move2 == STOP & (isCloser(buttonF, nextF2, nextF1) |
                                                          move1 == DOWN |
                                                          (move1 == UP & nextF1 > buttonF)))));
      end
   endtask // givFloorButton

   function isCloser;
      input [2:0] buttonF;
      input [2:0] closeF;
      input [2:0] farF;
      begin
         case ({closeF > buttonF, farF > buttonF})
           2'b00 : isCloser = (buttonF - closeF) < (buttonF - farF);
           2'b01 : isCloser = (buttonF - closeF) < (farF - buttonF);
           2'b10 : isCloser = (closeF - buttonF) < (buttonF - farF);
           2'b11 : isCloser = (closeF - buttonF) < (farF - buttonF);
         endcase // case ({closeF > buttonF, farF > buttonF})
      end
   endfunction // isCloser

endmodule // ElevatorController
