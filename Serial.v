`timescale 1ns / 1ps

module ArdParallelizer
  (
   input [38:0] serial,
   output [11:0] newRealFloorButton,
   output [9:1] newInternalButton1,
   output [9:1] newInternalButton2,
   output [9:1] newInternalButton3
   );

   assign newRealFloorButton = serial[38:27];
   assign newInternalButton1 = serial[26:18];
   assign newInternalButton2 = serial[17:9];
   assign newInternalButton3 = serial[8:0];

endmodule // ArdParallelizer

module EleConSerializer
  (
   input [11:0]  currentRealFloorButton,
   input [9:1]   currentInternalButton1,
   input [2:0]   currentFloor1,
   input [1:0]   currentDirection1,
   input         doorState1,
   input [9:1]   currentInternalButton2,
   input [2:0]   currentFloor2,
   input [1:0]   currentDirection2,
   input         doorState2,
   input [9:1]   currentInternalButton3,
   input [2:0]   currentFloor3,
   input [1:0]   currentDirection3,
   input         doorState3,
   output [56:0] serial
   );

   assign serial = {currentRealFloorButton,
                    currentInternalButton1,
                    currentFloor1,
                    currentDirection1,
                    doorState1,
                    currentInternalButton2,
                    currentFloor2,
                    currentDirection2,
                    doorState2,
                    currentInternalButton3,
                    currentFloor3,
                    currentDirection3,
                    doorState3};

endmodule // EleConSerializer
