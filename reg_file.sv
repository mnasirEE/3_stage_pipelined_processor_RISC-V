module reg_file #(parameter reg_addr_width = 5, reg_data_width = 32, reg_depth = 32)
    ( input logic [reg_addr_width -1:0] wr_addr, r_addr1, r_addr2,
    input logic [reg_data_width - 1:0] wr_data,
    input logic write_back_en, clk,
    output logic [reg_data_width - 1:0] r_data1, r_data2
);

reg [reg_data_width - 1:0] reg_file_16 [0:reg_depth-1];

// Flag to indicate if register file has been initialized
// bit reg_file_initialized = 0;
initial begin
    reg_file_16[0] = 32'h0; // x0 = 0 hard wire
    reg_file_16[1] = 32'h1;
    reg_file_16[3] = 32'h5;
    reg_file_16[4] = 32'h7;
end



// Reading data asynchronously
always @(*) begin
    r_data1 = reg_file_16[r_addr1];
    r_data2 = reg_file_16[r_addr2];
end

always @(negedge clk, posedge write_back_en) begin
    if (write_back_en) begin
        reg_file_16[wr_addr] <= wr_data;
    end
end
    

endmodule
