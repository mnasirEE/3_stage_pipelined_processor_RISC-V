module datapath_tb;

parameter addr_data_width = 32;
logic [addr_data_width -1] PC1;
logic reset_1,clk_1;
logic [addr_data_width-1:0] alu_out1;
logic [31:0] wr_back_data1;

localparam period = 10;

datapath UUT(
    .PC(PC1),
    .reset1(reset_1),
    .clk1(clk_1),
    .alu_out(alu_out1),
    .wr_back_data(wr_back_data1)
);

always #(period/2) clk_1 = ~clk_1; // clock generation

initial begin
    clk_1 = 0;
    reset_1 = 1;
    @(posedge clk_1); reset_1 = 0;

    repeat(15) begin
        @(posedge clk_1);

    end
    $stop;

end
    
endmodule