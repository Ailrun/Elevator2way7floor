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
   wire [13:0] cFB1, cFB2, uFBI, uFBO;
   wire [1:0]  sC1, sC2;
   wire        move1, move2;

   // Instantiate the Unit Under Test (UUT)
   ElevatorController#(40,40,0) uut
     (
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
      .doorState2(doorState2),
      .currentFloorButton1(cFB1),
      .currentFloorButton2(cFB2),
      .unusedFloorButtonIn(uFBI),
      .unusedFloorButtonOut(uFBO),
      .move1(move1),
      .move2(move2),
      .sC1(sC1),
      .sC2(sC2)
      );


   initial begin
      clk = 0;
      reset = 1;
      nRFB = 0;
      nIB1 = 0;
      nIB2 = 0;
      #10000;
      reset = 0;

      #10000;
      nRFB = 12'b0_00_01_01_00_00_1;
      #100;
      nRFB = 0;

      #20000;
      nIB1 = 9'b00_000_1010;
      nIB2 = 9'b00_000_1001;
      #100;
      nIB1 = 0;
      nIB2 = 0;

      #20000;
      nIB1 = 9'b10_000_0010;
      nIB2 = 9'b00_001_0010;
      nRFB = 12'b1_00_00_01_00_10_0;
      #100;
      nIB1 = 0;
      nIB2 = 0;
      nRFB = 0;

      #10000;
      nRFB = 12'b0_10_00_00_01_00_0;
      #100;
      nRFB = 0;

      #30000;
      nIB1 = 9'b00_000_0101;
      nIB2 = 9'b10_000_1001;
      nRFB = 12'b0_00_00_00_00_10_0;
      #100;
      nIB1 = 0;
      nIB2 = 0;
      nRFB = 0;

      #20000;
      nIB1 = 9'b00_000_0100;
      nRFB = 12'b0_00_00_10_00_01_0;
      #100;
      nIB1 = 0;
      nRFB = 0;

      #40000;
      nIB1 = 9'b00_000_0100;
      nIB2 = 9'b00_000_0100;
      nRFB = 12'b0_00_11_00_01_00_0;
      #100;
      nIB1 = 0;
      nIB2 = 0;
      nRFB = 0;

      #40000;
      nIB1 = 9'b10_000_1010;
      nIB2 = 9'b00_001_1000;
      nRFB = 12'b0_00_00_00_10_00_0;
      #100;
      nIB1 = 0;
      nIB2 = 0;
      nRFB = 0;

      #10000;
      nIB1 = 9'b00_000_0100;
      nRFB = 12'b1_00_00_10_00_11_0;
      #100;
      nIB1 = 0;
      nRFB = 0;

      #20000;
      nIB1 = 9'b00_001_0100;
      nIB2 = 9'b00_001_0000;
      #100;
      nIB1 = 0;
      nIB2 = 0;

      #100000;
      nIB2 = 9'b10_000_0000;
      nRFB = 12'b0_00_01_00_01_10_0;
      #100;
      nIB2 = 0;
      nRFB = 0;

      #10000;
      nRFB = 12'b0_00_00_01_00_10_0;
      #100;
      nRFB = 0;

      #10000;
      nIB1 = 9'b00_000_0001;
      nIB2 = 9'b00_000_1001;
      #100;
      nIB1 = 0;
      nIB2 = 0;

      #10000;
      nIB2 = 9'b00_000_1001;
      #100;
      nIB2 = 0;

      #20000;
      nRFB = 12'b0_00_00_00_01_10_0;
      #100;
      nRFB = 0;

      #20000;
      nIB1 = 9'b00_001_0000;
      nRFB = 12'b0_00_00_01_00_00_0;
      #100;
      nIB1 = 0;
      nRFB = 0;

      #200000;
      $finish;
   end

   always begin
      #25 clk = ~clk;
   end

endmodule
