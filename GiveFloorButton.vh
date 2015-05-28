`timescale 1ns / 1ps

module GiveFloorButton
  (
   input         clk,
   input         reset,
   input [13:0]  newFloorButton,
   input [13:0]  nextFloorButton1,
   input [13:0]  nextFloorButton2,
   input [13:0]  unusedFloorButtonIn,
   input [1:0]   direction1,
   input [1:0]   direction2,
   output [13:0] floorButton1,
   output [13:0] floorButton2,
   output [13:0] unusedFloorButtonOut
   );
