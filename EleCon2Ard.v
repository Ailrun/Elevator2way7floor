`timescale 1ns / 1ps

module EleCon2Ard
  (
   input  clk,
   input  reset,
   input  dataIn,
   output dataOut
   );

   reg [47:0] newData = 0;
   reg [47:0] currentData = 0;
   reg [5:0]  counter = 0;

   wire [47:0] usingData = ((counter != 47)? currentData : newData);
   wire        isValid = ((usingData[1:0] == 2'b00 ||
                           usingData[9:8] == 2'b00 ||
                           usingData[17:16] == 2'b00) &&
                          (usingData[1:0] == 2'b01 ||
                           usingData[9:8] == 2'b01 ||
                           usingData[17:16] == 2'b01) &&
                          (usingData[1:0] == 2'b10 ||
                           usingData[9:8] == 2'b10 ||
                           usingData[17:16] == 2'b10));
   wire [1:0]  direction1 = (isValid?
                             ((usingData[1:0] == 00)? usingData[3:2] :
                              (usingData[9:8] == 00)? usingData[11:10] :
                              (usingData[17:16] == 00)? usingData[19:18] :
                              2'b00) :
                             2'b00);
   wire [1:0]  direction2 = (isValid?
                             ((usingData[1:0] == 01)? usingData[3:2] :
                              (usingData[9:8] == 01)? usingData[11:10] :
                              (usingData[17:16] == 01)? usingData[19:18] :
                              2'b00) :
                             2'b00);

   wire

   ElevatorController eleCon()
