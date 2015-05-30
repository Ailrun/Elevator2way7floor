`timescale 1ns / 1ps

module EleCont_Test;

   // Inputs
   reg clk;
   reg reset;
   reg [11:0] nRFB;
   reg [9:1]  nIB1;
   reg [9:1]  nIB2;

   // Outputs
   wire [2:0] currentFloor1;
   wire [2:0] currentFloor2;
   wire [1:0] currentDirection1;
   wire [1:0] currentDirection2;
   wire [11:0] currentRealFloorButton;
   wire [9:1]  currentInternalButton1;
   wire [9:1]  currentInternalButton2;
   wire        doorState1;
   wire        doorState2;

   // Instantiate the Unit Under Test (UUT)
   ElevatorController uut (
                           .clk(clk),
                           .reset(reset),
                           .newRealFloorButton(nRFB),
                           .newInternalButton1(nIB1),
                           .newInternalButton2(nIB2),
                           .currentFloor1(currentFloor1),
                           .currentFloor2(currentFloor2),
                           .currentDirection1(currentDirection1),
                           .currentDirection2(currentDirection2),
                           .currentRealFloorButton(currentRealFloorButton),
                           .currentInternalButton1(currentInternalButton1),
                           .currentInternalButton2(currentInternalButton2),
                           .doorState1(doorState1),
                           .doorState2(doorState2)
                           );


   initial begin
      clk = 0;
      reset = 1;
      nRFB = 0;
      nIB1 = 0;
      nIB2 = 0;
      #20;
      reset = 0;
      #100;

      nRFB = 12'b 1_00_01_01_00_00_0;
      nIB1 = 0;
      nIB2 = 0;
      #100;
      nIB1 = 9'b 00_0010_010;
      nRFB = 0;
      #100;
      nIB1 = 0;
      nRFB = 12'b 0_00_10_10_00_10_1;
      #100;
      nRFB = 0;
      nIB2 = 9'b 00_0100_100;
      #100;
      nIB2 = 0;

      #100000;
      $finish;
   end

   always begin
      #10 clk = ~clk;
   end

endmodule

