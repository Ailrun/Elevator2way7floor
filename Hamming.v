`timescale 1ns / 1ps

module synMake
  (
   input [6:0]  data,
   output [2:0] syn
   );

   assign syn = {data[5]^data[4]^data[3]^data[2],
                 data[6]^data[4]^data[3]^data[1],
                 data[6]^data[5]^data[4]^data[0]};
endmodule // synMake



module HammingDecoder
  (
   input [6:0]  received,
   output [3:0] data
   );

   wire [2:0]   syn;

   synMake syndrome(received[6:0],syn);

   assign data = {(syn == 3'b011)? ~received[6] : received[6],
                  (syn == 3'b101)? ~received[5] : received[5],
                  (syn == 3'b110)? ~received[4] : received[4],
                  (syn == 3'b111)? ~received[3] : received[3]};

endmodule // HammingDecoder

module HammingEncoder
  (
   input [3:0]  data,
   output [6:0] message
   );

   wire [2:0]   adding;

   synMake addingValue({data, 3'b000}, adding);

   assign message = {data, adding};

endmodule // HammingEncoder



module SerialHammingDecoder#(parameter N = 8)
   (
    input [8*(N/4 + (N%4 != 2'b00)):1] hammedData,
    output [N:1]                       data
    );

   localparam Leng = 8*(N/4 + (N%4 != 2'b00));

   wire [Leng/2:1]                     extendedData;

   genvar                              ind0;
   generate
      for (ind0 = 1; ind0 < N/4 + 1; ind0 = ind0 + 1)
        begin : gen0
           HammingDecoder ham(.received(hammedData[8*ind0:8*ind0-6]),
                              .data(extendedData[4*ind0:4*ind0-3]));
        end
   endgenerate

   assign data = extendedData[Leng/2:Leng/2-N+1];

endmodule // SerialHammingDecoder

module SerialHammingEncoder#(parameter N = 8)
   (
    input [N:1]                     data,
    output [8*(N/4 + (N%4 != 2'b00)):1] hammedData
    );

   localparam Leng = 8*(N/4 + (N%4 != 2'b00));

   wire [Leng/2:1]                  extendedData;

   genvar                           ind0;
   generate
      for (ind0 = 1; ind0 < Leng/2 + 1; ind0 = ind0 + 1)
        begin : gen0
           if (ind0 + N > Leng/2)
             begin
                assign extendedData[ind0] = data[ind0 + N - Leng/2];
             end
           else
             begin
                assign extendedData[ind0] = 1'b0;
             end
        end // for (ind0 = 1; ind0 < Leng/2 + 1; ind0 = ind0 + 1)
   endgenerate

   genvar                          ind1;
   generate
      for (ind1 = 1; ind1 < N/4 + 1; ind1 = ind1 + 1)
        begin : gen1
           assign hammedData[8*ind1-7] = 1'b0;
           HammingEncoder ham(.data(extendedData[4*ind1:4*ind1-3]),
                              .message(hammedData[8*ind1:8*ind1-6]));
        end
   endgenerate

endmodule // SerialHammingEncoder
