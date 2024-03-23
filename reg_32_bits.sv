// reg_32_bits reg1 (.data_in(), 
//                   .clock(), 
//                   .reset(), 
//                   .data_out());
module reg_32_bits #(
    parameter data_width = 32
) (
    input logic [data_width - 1:0] data_in,
    input logic clock,
    input logic reset,
    output logic [data_width - 1:0] data_out
);
// 32 bit register
// reg [data_width - 1:0] register_32_bits;

always_ff @( posedge clock, posedge reset ) begin : register
    if (reset) begin
        data_out <= 32'b0;
    end
    else begin
        data_out <= data_in;
    end
end

// always @(*) begin
//     data_out = register_32_bits;
// end
    
endmodule