`timescale 1ns / 1ps

module Director
  ( //first
    input            clk,
    input            enable
    input            reset,
    input [2:0]      currentFloor,
    input [1:0]      currentDirection,
    input [13:0]     floorButton,
    input [9:1]      internalButton,
    input            doorState,
    input            move,
    output reg [1:0] nextDirection
    );

   localparam ON = 1'b1, OFF = 1'b0,
     MOVE = 1'b1, HOLD = 1'b0,
     OPEN = 1'b1, CLOSE = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11;

   wire         anyUpper = upper(currentFloor, floorButton, internalButton);
   wire         anyLower = lower(currentFloor, floorButton, internalButton);

   always @(posedge clk)
     begin
        if (reset == ON)
          begin
             nextDirection <= STOP;
          end
        else if (enable == ON)
          begin
             if (move == HOLD)
               begin
                  if (doorState == CLOSE)
                    case (currentDirection)
                      STOP :
                        begin
                           if (anyUpper == ON)
                             nextDirection <= UP;
                           else if (anyLower == ON)
                             nextDirection <= DOWN;
                        end
                      UP :
                        begin
                           if (anyUpper == OFF)
                             begin
                                if (anyLower == ON)
                                  nextDirection <= DOWN;
                                else
                                  nextDirection <= STOP;
                             end
                        end
                      DOWN :
                        begin
                           if (anyLower == OFF)
                             begin
                           if (anyUpper == ON)
                             nextDirection <= UP;
                           else
                             nextDirection <= STOP;
                             end
                        end
                      UPDOWN :
                        $display("ERROR in Director\n");
                    endcase // case (currentDirection)
               end // if (move == HOLD)
          end // if (enable == ON)
     end // always @ (posedge clk)

   function upper;
      input [2:0]  currentFloor;
      input [13:0] floorButton;
      input [9:1]  internalButton;
      begin
         upper = (currentFloor < 2 &&
                  (internalButton[2] == ON ||
                   !isIn(STOP, floorButton[3:2]))) ||
                 (currentFloor < 3 &&
                  (internalButton[3] == ON ||
                   !isIn(STOP, floorButton[5:4]))) ||
                 (currentFloor < 4 &&
                  (internalButton[4] == ON ||
                   !isIn(STOP, floorButton[7:6]))) ||
                 (currentFloor < 5 &&
                  (internalButton[5] == ON ||
                   !isIn(STOP, floorButton[9:8]))) ||
                 (currentFloor < 6 &&
                  (internalButton[6] == ON ||
                   !isIn(STOP, floorButton[11:10]))) ||
                 (currentFloor < 7 &&
                  (internalButton[7] == ON ||
                   !isIn(STOP, floorButton[13:12])));
      end
   endfunction // upper

   function lower;
      input [2:0]  currentFloor;
      input [13:0] floorButton;
      input [9:1]  internalButton;
      begin
         lower = (currentFloor > 1 &&
                  (internalButton[1] == ON ||
                   !isIn(STOP, floorButton[1:0]))) ||
                 (currentFloor > 2 &&
                  (internalButton[2] == ON ||
                   !isIn(STOP, floorButton[3:2]))) ||
                 (currentFloor > 3 &&
                  (internalButton[3] == ON ||
                   !isIn(STOP, floorButton[5:4]))) ||
                 (currentFloor > 4 &&
                  (internalButton[4] == ON ||
                   !isIn(STOP, floorButton[7:6]))) ||
                 (currentFloor > 5 &&
                  (internalButton[5] == ON ||
                   !isIn(STOP, floorButton[9:8]))) ||
                 (currentFloor > 6 &&
                  (internalButton[6] == ON ||
                   !isIn(STOP, floorButton[11:10])));
      end
   endfunction // lower

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
           UPDOWN : $display("ERROR in Door!");
         endcase // case (currentDirection)
      end
   endfunction // isIn

endmodule // Director
