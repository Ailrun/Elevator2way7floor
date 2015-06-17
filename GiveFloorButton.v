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

   wire [1:0] getButton[1:3];

   wire       isUp, isDown;

   LRUControl(LRUIn, getButton[1], getButton[2], getButton[3], LRUOut);

   ToUpClosest(LRUIn,
               buttonFloor, currentFloor1, currentFloor2. currentFloor3,
               upClosest, upStill);
   assign isUp = (upStill? wholeButton[1] :
                  (unusedFloorButtonIn | newFloorButton)[1]);
   ToDownClosest(LRUIn,
                 buttonFloor, currentFloor1, currentFloor2. currentFloor3,
                 downClosest, downStill);
   assign isDown = isUp? 0 :
                   (downStill? wholeButton[1] :
                    (unusedFloorButtonIn | newFloorButton)[0]);
   getButton[1][1] = (upClosest == 1 ? isUp);
   getButton[2][1] = (upClosest == 2 ? isUp);
   getButton[3][1] = (upClosest == 3 ? isUp);

   getButton[1][0] = (downClosest == 1 ? isDown);
   getButton[2][0] = (downClosest == 2 ? isDown);
   getButton[3][0] = (downClosest == 3 ? isDown);

   assign nextFloorButton1 = reset?2'b0:
                             ((currentFloorButton1 | getButton[1]) &
                              ~(getButton[2] | getButton[3]));
   assign nextFloorButton2 = reset?2'b0:
                             ((currentFloorButton2 | getButton[2]) &
                              ~(getButton[1] | getButton[3]));
   assign nextFloorButton3 = reset?2'b0:
                             ((currentFloorButton3 | getButton[3]) &
                              ~(getButton[1] | getButton[2]));

   assign unusedFloorButtonOut = reset?2'b0:
                                 (wholeButton &
                                  ~(nextFloorButton1 |
                                    nextFloorButton2 |
                                    nextFloorButton3));

   task ToUpClosest;
      input [6:1] LRU;
      input [2:0] buttonFloor;
      input [2:0] currentFloor1;
      input [2:0] currentFloor2;
      input [2:0] currentFloor3;
      input [1:0] direction1;
      input [1:0] direction2;
      input [1:0] direction3;
      output [1:0] closestNum;
      output       still;
      begin
         case ({currentFloor1 > buttonFloor,
                currentFloor2 > buttonFloor,
                currentFloor3 > buttonFloor,
                currentFloor1 > currentFloor2,
                currentFloor2 > currentFloor3,
                currentFloor3 > currentFloor1,
                currentFloor1 == currentFloor2,
                currentFloor2 == currentFloor3,
                currentFloor3 == currentFloor1})
           9'b000_000_111 : closestNum = (LRU[6:5] == 1 ? 1 :
                                     LRU[4:3] == 1 ? 2 : 3);
           9'b000_001_100, 9'b000_101_000, 9'b010_011_000, 9'b100_100_000,
             9'b110_010_000, 9'b110_010_100, 9'b110_110_000 :
             closestNum = 3;
           9'b000_010_001, 9'b000_011_000, 9'b001_001_000, 9'b100_110_000,
             9'b101_100_000, 9'b101_100_001, 9'b101_101_000 :
             closestNum = 2;
           9'b000_100_010, 9'b000_110_000, 9'b001_101_000, 9'b010_010_000,
             9'b011_001_000, 9'b011_001_010, 9'b011_011_000:
             closestNum = 1;
           9'b000_010_100, 9'b001_001_100 :
             closestNum = (LRU[6:5] < LRU[4:3] ? 1 : 2);
           9'b000_100_001, 9'b010_010_001 :
             closestNum = (LRU[6:5] < LRU[2:1] ? 1 : 3);
           9'b000_001_010, 9'b100_100_010 :
             closestNum = (LRU[4:3] < LRU[2:1] ? 2 : 3);
           default :
             closestNum = 1;
         endcase // case ({currentFloor1 > buttonFloor,...

         still = (closestNum == 1? buttonFloor == currentFloor1 :
                  (closestNum == 2? buttonFloor == currentFloor2 :
                   buttonFloor == currentFloor3));
      end
   endtask // ToUpClosest

   task ToDownClosest;
      input [6:1] LRU;
      input [2:0] buttonFloor;
      input [2:0] currentFloor1;
      input [2:0] currentFloor2;
      input [2:0] currentFloor3;
      input [1:0] direction1;
      input [1:0] direction2;
      input [1:0] direction3;
      output [1:0] closestNum;
      output       still;
         case ({currentFloor1 < buttonFloor,
                currentFloor2 < buttonFloor,
                currentFloor3 < buttonFloor,
                currentFloor1 < currentFloor2,
                currentFloor2 < currentFloor3,
                currentFloor3 < currentFloor1,
                currentFloor1 == currentFloor2,
                currentFloor2 == currentFloor3,
                currentFloor3 == currentFloor1})
           9'b000_000_111 : closestNum = (LRU[6:5] == 1 ? 1 :
                                     LRU[4:3] == 1 ? 2 : 3);
           9'b000_001_100, 9'b000_101_000, 9'b010_011_000, 9'b100_100_000,
             9'b110_010_000, 9'b110_010_100, 9'b110_110_000 :
             closestNum = 3;
           9'b000_010_001, 9'b000_011_000, 9'b001_001_000, 9'b100_110_000,
             9'b101_100_000, 9'b101_100_001, 9'b101_101_000 :
             closestNum = 2;
           9'b000_100_010, 9'b000_110_000, 9'b001_101_000, 9'b010_010_000,
             9'b011_001_000, 9'b011_001_010, 9'b011_011_000:
             closestNum = 1;
           9'b000_010_100, 9'b001_001_100 :
             closestNum = (LRU[6:5] < LRU[4:3] ? 1 : 2);
           9'b000_100_001, 9'b010_010_001 :
             closestNum = (LRU[6:5] < LRU[2:1] ? 1 : 3);
           9'b000_001_010, 9'b100_100_010 :
             closestNum = (LRU[4:3] < LRU[2:1] ? 2 : 3);
           default :
             closestNum = 1;
         endcase // case ({currentFloor1 < buttonFloor,...

         still = (closestNum == 1? buttonFloor == currentFloor1 :
                  (closestNum == 2? buttonFloor == currentFloor2 :
                   buttonFloor == currentFloor3));
      end
   endtask // ToDownClosest

   task LRUControl;
      input [6:1] LRUIn;
      input [1:0] getButton1, getButton2, getButton3;
      output [6:1] LRUOut;
      begin
         case (LRUIn)
           {2'd1, 2'd2, 2'd3} :
             if (getButton1)
               LRUOut = {2'd3, 2'd1, 2'd2};
             else if (getButton2)
               LRUOut = {2'd1, 2'd3, 2'd2};
             else
               LRUOut = LRUIn;
           {2'd1, 2'd3, 2'd2} :
             if (getButton1)
               LRUOut = {2'd3, 2'd2, 2'd1};
             else if (getButton3)
               LRUOut = {2'd1, 2'd2, 2'd3};
             else
               LRUOut = LRUIn;
           {2'd2, 2'd1, 2'd3} :
             if (getButton1)
               LRUOut = {2'd3, 2'd1, 2'd2};
             else if (getButton2)
               LRUOut = {2'd1, 2'd3, 2'd2};
             else
               LRUOut = LRUIn;
           {2'd2, 2'd3, 2'd1} :
             if (getButton1)
               LRUOut = {2'd3, 2'd2, 2'd1};
             else if (getButton3)
               LRUOut = {2'd1, 2'd2, 2'd3};
             else
               LRUOut = LRUIn;
           {2'd3, 2'd1, 2'd2} :
             if (getButton2)
               LRUOut = {2'd2, 2'd3, 2'd1};
             else if (getButton3)
               LRUOut = {2'd2, 2'd1, 2'd3};
             else
               LRUOut = LRUIn;
           {2'd3, 2'd2, 2'd1} :
             if (getButton2)
               LRUOut = {2'd2, 2'd3, 2'd1};
             else if (getButton3)
               LRUOut = {2'd2, 2'd1, 2'd3};
             else
               LRUOut = LRUIn;
         endcase // case (LRUIn)
      end
   endtask // LRUControl
endmodule // SubGive
