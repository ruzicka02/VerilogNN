`timescale 1ns / 1ps

`include "src/NeuralLayer.v"
// `include "src/DisplayFloat.v"

// https://stackoverflow.com/questions/31010070/verilog-vector-packing-unpacking-macro
`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST,PK_IDX) \
for (genvar PK_IDX=0; PK_IDX<(PK_LEN); PK_IDX=PK_IDX+1) begin \
    assign PK_DEST[(PK_WIDTH)*PK_IDX +: PK_WIDTH] = PK_SRC[PK_IDX][((PK_WIDTH)-1):0]; \
end

module NeuralNetworkTB #(parameter L0 = 10, L1 = 5, L2 = 5, L3 = 5);  // input size (L0) + numbers of neurons in 3 layers

    wire [(32 * L0) - 1:0] in;
    wire [(32 * L1) - 1:0] potential1;
    wire [(32 * L2) - 1:0] potential2;
    wire [(32 * L3) - 1:0] result;  // result == potential of final output layer after activation
    wire [(32 * L0 * L1) - 1:0] weights1;
    wire [(32 * L1 * L2) - 1:0] weights2;
    wire [(32 * L2 * L3) - 1:0] weights3;

    reg  [31:0] in_arr [0:L0 - 1];
    reg  [31:0] weights1_arr [0:(L0 * L1) - 1];
    reg  [31:0] weights2_arr [0:(L1 * L2) - 1];
    reg  [31:0] weights3_arr [0:(L2 * L3) - 1];

    NeuralLayer #(.IN_SIZE(L0), .OUT_SIZE(L1)) layer1 (.in(in        ), .weights(weights1), .activation(1'b0), .result(potential1));
    NeuralLayer #(.IN_SIZE(L1), .OUT_SIZE(L2)) layer2 (.in(potential1), .weights(weights2), .activation(1'b0), .result(potential2));
    NeuralLayer #(.IN_SIZE(L2), .OUT_SIZE(L3)) layer3 (.in(potential2), .weights(weights3), .activation(1'b1), .result(result));

    // Terminal displaying... WIP

    // for (genvar i = 0; i < L3; i = i + 1) begin
    //     reg id_[3 * 8:1];
    //     // $sformat(id_, "%d", i);
    //     id_[8:1] = 8'h30;  // 0x30 is "0" in ASCII
    //     DisplayFloat display_result (.num(result[32 * i +: 32]), .id(id_), .format(1'b1));
    // end

    // unpack memory arrays to long vectors
    `PACK_ARRAY(32, L0, in_arr, in, pack1);
    `PACK_ARRAY(32, L0 * L1, weights1_arr, weights1, pack2);
    `PACK_ARRAY(32, L1 * L2, weights2_arr, weights2, pack3);
    `PACK_ARRAY(32, L2 * L3, weights3_arr, weights3, pack4);

    // load values from memory
    initial
    begin
        #1
        $readmemb("data/placeholder500.mem", in_arr, 0, L0 - 1);
        $readmemb("data/placeholder500.mem", weights1_arr, 0, (L0 * L1) - 1);
        $readmemb("data/placeholder500.mem", weights2_arr, 0, (L1 * L2) - 1);
        $readmemb("data/placeholder500.mem", weights3_arr, 0, (L2 * L3) - 1);
    end

    // displaying
    initial
    begin
        // dump to vcd file for GTKWave
        $dumpfile("vcd/NeuralNetworkTB.vcd");
        $dumpvars;

        #100
        $display("Expected Values: TODO");

        $finish;
    end

endmodule