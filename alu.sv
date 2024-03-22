module alu (
    input logic [31:0] operand_a, operand_b,
    input logic [3:0] select_op,
    output logic [31:0] result_out
);

always @(*)
    case (select_op)
       4'b0000 : result_out = operand_a + operand_b; // add 
       4'b0001 : result_out = operand_a - operand_b; // sub
       4'b0010 : result_out = operand_a << operand_b; // sll 
    //    4'b0011 : result_out = operand_a + operand_b; // slt
    //    4'b0100 : result_out = operand_a + operand_b; // sltu
       4'b0101 : result_out = operand_a ^ operand_b; // xor
       4'b0110 : result_out = operand_a >> operand_b; // srl
    //    4'b0111 : result_out = operand_a + operand_b; // sra
       4'b1000 : result_out = operand_a | operand_b; // or 
       4'b1001 : result_out = operand_a & operand_b; // and
       default: result_out = operand_a + operand_b;
    endcase
    
endmodule