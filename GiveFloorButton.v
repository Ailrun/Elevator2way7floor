`timescale 1ns / 1ps

module GiveFloorButton
  (
   input         clk,
   input         reset,
   input [2:0]   currentFloor1,
   input [2:0]   currentFloor2,
   input [2:0]   currentFloor3,
   input [13:0]  newFloorButton,
   input [13:0]  currentFloorButton1,
   input [13:0]  currentFloorButton2,
   input [13:0]  currentFloorButton3,
   input [13:0]  unusedFloorButtonIn,
   input [1:0]   direction1,
   input [1:0]   direction2,
   input [1:0]   direction3,
   output [13:0] nextFloorButton1,
   output [13:0] nextFloorButton2,
   output [13:0] nextFloorButton3,
   output [13:0] unusedFloorButtonOut
   );

   reg [6:1]     LRU;
   wire [6:1]    LRUwire[8:1];

   assign LRUwire[1] = LRU;

   genvar        i;
   generate
      for (i = 0; i < 7; i = i + 1)
        begin : subgen
           SubGive sub(clk, reset, LRUwire[i+1], LRUwire[i+2], i+1,
                       currentFloor1, currentFloor2, currentFloor3,
                       newFloorButton[2*i+1:2*i],
                       currentFloorButton1[2*i+1:2*i],
                       currentFloorButton2[2*i+1:2*i],
                       currentFloorButton3[2*i+1:2*i],
                       unusedFloorButtonIn[2*i+1:2*i],
                       direction1, direction2, direction3,
                       nextFloorButton1[2*i+1:2*i],
                       nextFloorButton2[2*i+1:2*i],
                       nextFloorButton3[2*i+1:2*i],
                       unusedFloorButtonOut[2*i+1:2*i]);
        end // block: subgen
   endgenerate

   always @(posedge clk)
     begin
        if (reset)
          LRU <= 6'b0;
        else
          LRU <= LRUwire[8];
     end

endmodule // GiveFloorButton

module SubGive
  (
   input        clk,
   input        reset,
   input [6:1]  LRUIn,
   input [6:1]  LRUOut,
   input [2:0]  buttonFloor,
   input [2:0]  currentFloor1,
   input [2:0]  currentFloor2,
   input [2:0]  currentFloor3,
   input [1:0]  newFloorButton,
   input [1:0]  currentFloorButton1,
   input [1:0]  currentFloorButton2,
   input [1:0]  currentFloorButton3,
   input [1:0]  unusedFloorButtonIn,
   input [1:0]  direction1,
   input [1:0]  direction2,
   input [1:0]  direction3,
   output [1:0] nextFloorButton1,
   output [1:0] nextFloorButton2,
   output [1:0] nextFloorButton3,
   output [1:0] unusedFloorButtonOut
   );

   localparam STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     ON = 1'b1, OFF = 1'b0;

   wire [1:0] wholeButton = newFloorButton |
              currentFloorButton1 |
              currentFloorButton2 |
              currentFloorButton3 |
              unusedFloorButtonIn;

   wire [1:0] getButton1, getButton2, getButton3;

   assign getButton1 = reset?0:
                       (
                        );
   assign getButton2 = reset?0:
                       (
                        );
   assign getButton3 = reset?0:
                       (
                        );

   assign nextFloorButton1 = reset?0:
                             ((currentFloorButton1 | getButton1) &
                              ~(getButton2 | getButton3));
   assign nextFloorButton2 = reset?0:
                             ((currentFloorButton2 | getButton2) &
                              ~(getButton1 | getButton3));
   assign nextFloorButton3 = reset?0:
                             ((currentFloorButton3 | getButton3) &
                              ~(getButton1 | getButton2));

   assign unusedFloorButtonOut = reset?0:
                                 ((unusedFloorButtonIn | newFloorButton) &
                                  ~(nextFloorButton1 |
                                    nextFloorButton2 |
                                    nextFloorButton3));

   function isCloser;
      input [2:0] buttonFloor;
      input [2:0] closeFloor;
      input [2:0] farFloor;
      begin
         case ({buttonFloor > closeFloor, buttonFloor > farFloor})
           2'b00 :
             isCloser = (closeFloor - buttonFloor) < (farFloor - buttonFloor);
           2'b01 :
             isCloser = (closeFloor - buttonFloor) < (buttonFloor - farFloor);
           2'b10 :
             isCloser = (buttonFloor - closeFloor) < (farFloor - buttonFloor);
           2'b11 :
             isCloser = (buttonFloor - closeFloor) < (buttonFloor - farFloor);
         endcase // case ({buttonFloor > closeFloor, buttonFloor > farFloor})
      end
   endfunction // isCloser

endmodule // SubGive
