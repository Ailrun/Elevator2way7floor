`timescale 1ns / 1ps

module Ele_each_test;

   // Inputs
   reg clk;
   reg reset;
   reg [13:0] newbutton;
   reg [9:1]  newIbutton;
   reg [13:0] floorButton;
   reg [9:1]  internalButton;

   // Outputs
   wire [2:0] nextFloor;
   wire [1:0] nextDirection;
   wire [13:0] nextFloorButton;
   wire [9:1]  nextInternalButton;
   wire        doorState;

   // Instantiate the Unit Under Test (UUT)
   Elevator#(10,10,10) uut (
                            .clk(clk),
                            .reset(reset),
                            .floorButton(nextFloorButton | newbutton),
                            .internalButton(nextInternalButton | newIbutton),
                            .nextFloor(nextFloor),
                            .nextDirection(nextDirection),
                            .nextFloorButton(nextFloorButton),
                            .nextInternalButton(nextInternalButton),
                            .doorState(doorState),
                            );

   initial begin
      clk = 0;
      reset = 1;
      newbutton = 0;
      newIbutton = 0;
      #30;
      reset = 0;
      #50;
      #1000;
      newbutton = 14'b00_00_00_10_00_00_00;
      #1000;
      newIbutton = 9'b00_010_0000;
      #2000;
      newbutton = 0;
      #1000;
      newIbutton = 0;
      #1000;
      newbutton = 14'b01_00_00_00_00_11_00;
      #2000;
      newIbutton = 9'b00_100_0001;
      #1000;
      newbutton = 0;
      #2000;
      newIbutton = 0;
      #14000;
      newIbutton = 9'b01_000_0000;
      #1000;
      newIbutton = 0;
      #10000;
      $finish;
      // Add stimulus here

   end

   always begin
      #10 clk = ~clk;
   end

   always @(posedge clk) begin
      floorButton = nextFloorButton | newbutton;
   end

   always @(posedge clk) begin
      internalButton = nextInternalButton | newIbutton;
   end

endmodule
