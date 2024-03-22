
// controller c1 (.instruction(), .alu_op(), .regfile_write_enable());
module controller #(parameter instr_width = 32, alu_op_width = 4)
    ( input logic [instr_width - 1:0] instruction, // 32bit instruction - input port
    output logic [alu_op_width -1:0] alu_op, // alu operation selection
    output logic regfile_write_enable,       // write enable signal for regfile
    output logic sel_bw_imm_rs2, // select between imm and rs2
    output logic dmem_read_en, // data memory read enable signal for load instructions
    output logic wr_back_sel, // write back selection signal
    output logic dmem_write_en // data memory write enable for store operations
    
);
// type of alu operation is selected by opcode, func3 and func7
logic [6:0] opcode;
logic [2:0] func3;
logic [6:0] func7;
assign opcode = instruction[6:0];
assign func3 = instruction[14:12];
assign func7 = instruction[31:25];

// Arithmetic and logical operations
// R_type operations - 10 I_type operations 9
logic [3:0] add; // addition - add = addi
logic [3:0] sub; // subtraction - sub !=subi as there is no subi operation in I_format
logic [3:0] sll; // shift left logical - sll = slli - zeros extention
logic [3:0] slt; // set less than - signed by default- slt = slti
logic [3:0] sltu; // set less than unsigned - sltu = sltui
logic [3:0] Xor; // exclusive or gate/operation - xor = xori
logic [3:0] srl; // shift right logical - srl = srli - zeros extension
logic [3:0] sra; // shift right arithmetic - sra = srai
logic [3:0] OR; // or gate/operation - or = ori
logic [3:0] And; // and gate/operation - and = andi

assign    add = 4'b0000; 
assign    sub = 4'b0001;
assign    sll = 4'b0010;
assign    slt = 4'b0011;
assign    sltu = 4'b0100;
assign    Xor = 4'b0101;
assign    srl = 4'b0110;
assign    sra = 4'b0111;
assign    OR = 4'b1000;
assign    And = 4'b1001;


// generating alu_op signals 
// R_type
always @ (*)  
    case (opcode)
        7'b0110011: begin
            case (func3)
                3'b000: begin
                    case (func7)
                        7'b0000000: alu_op = add;
                        7'b0100000: alu_op = sub; 
                        default: alu_op = add;
                    endcase
                end
                3'b001: alu_op = sll; // shift left logical
                3'b010: alu_op = slt; // set less than
                3'b011: alu_op = sltu; // set less than unsigned
                3'b100: alu_op = Xor; // xor
                3'b101: begin
                    case (func7)
                        7'b0000000: alu_op = srl; // shift right logical
                        7'b0100000: alu_op = sra; // shift right arithmetic
                        default: alu_op = srl;
                    endcase
                end
                3'b110: alu_op = OR; // or
                3'b111: alu_op = And; // and
                
                
                default: alu_op = OR;
            endcase
        end
        // I_type - generating alu_op signals 
        // for load instructions alu op = addi = add
        // load instructions - 5
        7'b0000011 : begin
            case (func3)
                3'b000: alu_op = add; // addi - load byte - lb -func3 = 0
                3'b001: alu_op = add; // addi - load half word - lh - func3 = 1
                3'b010: alu_op = add; // addi - load word - lw - func3 = 2
                3'b100: alu_op = add; // addi - load byte unsigned  - lbu - func3 = 4
                3'b101: alu_op = add; // addi - load halfword unsigned - lhu -func3 = 5
                default: alu_op = add; // addi load word
            endcase
        end
    // arithmetic and logical instructions - 9
        7'b0010011 : begin
            case (func3)
                3'b000: alu_op = add; // add = addi   -func3 = 0
                3'b001: alu_op = sll; //sll = slli  - func3 = 1
                3'b010: alu_op = slt; // slt = slti -  - func3 = 2
                3'b011: alu_op = sltu; //  sltu = sltui - func3 = 3
                3'b100: alu_op = Xor; // Xor = xori -   - func3 = 4
                3'b101: begin // func3 = 5
                    case (func7)
                        7'b0000000 : alu_op = srl; // srl = srli - func7 = 0
                        7'b0100000 : alu_op = sra; // sra = srai - func7 = 32
                        default: alu_op = sra;
                    endcase
                end
                3'b110 : alu_op = OR ; // or = ori - func3 = 6
                3'b111 : alu_op = And ; // and = andi - func3 = 7
                default: alu_op = OR ; 
            endcase
        end

        // S_type instructions
        // S_type format for choosing operation
        // opcode = 35
        7'b0100011 : begin
            case (func3) // 0, 1, 2
                3'b000: alu_op = add; // address calculation - store byte
                3'b001: alu_op = add; // address calculation - store half word
                3'b010: alu_op = add; // address calculation - store word
                default: alu_op = add;
            endcase
        end
        default: alu_op = add;
    endcase


always @(*) begin 
    case (opcode)
        7'b0110011: regfile_write_enable = 1'b1; // R_type
        7'b0000011: regfile_write_enable = 1'b1; // I_type load instructions
        7'b0010011: regfile_write_enable = 1'b1; // I_type logical and arithmetic instructions
        default: regfile_write_enable = 1'b0; // for not write back instructions
    endcase
end

// Different always blocks for selectiing alu operation will through error - so use same block for all instructions in
// selecting type of operation 

// always @(*) begin
//     case (opcode)
//     // load instructions - 5
//         7'b0000011 : begin
//             case (func3)
//                 3'b000: alu_op = add; // addi - load byte - lb -func3 = 0
//                 3'b001: alu_op = add; // addi - load half word - lh - func3 = 1
//                 3'b010: alu_op = add; // addi - load word - lw - func3 = 2
//                 3'b100: alu_op = add; // addi - load byte unsigned  - lbu - func3 = 4
//                 3'b101: alu_op = add; // addi - load halfword unsigned - lhu -func3 = 5
//                 default: alu_op = add; // addi load word
//             endcase
//         end
//     // arithmetic and logical instructions - 9
//         7'b0010011 : begin
//             case (func3)
//                 3'b000: alu_op = add; // add = addi   -func3 = 0
//                 3'b001: alu_op = sll; //sll = slli  - func3 = 1
//                 3'b010: alu_op = slt; // slt = slti -  - func3 = 2
//                 3'b011: alu_op = sltu; //  sltu = sltui - func3 = 3
//                 3'b100: alu_op = Xor; // Xor = xori -   - func3 = 4
//                 3'b101: begin // func3 = 5
//                     case (func7)
//                         7'b0000000 : alu_op = srl; // srl = srli - func7 = 0
//                         7'b0100000 : alu_op = sra; // sra = srai - func7 = 32
//                         default: alu_op = sra;
//                     endcase
//                 end
//                 3'b110 : alu_op = OR ; // or = ori - func3 = 6
//                 3'b111 : alu_op = And ; // and = andi - func3 = 7
//                 default: alu_op = OR ; 
//             endcase
//         end
//         default: alu_op = add ;
//     endcase
// end

// I_type immediate selection
// generation of "sel_bw_imm_rs2" signal - select between imm and rs2

always @(*) begin
    // opcode = 3 for load op and 19 for arithmetic and logical op
    if( (opcode == 7'b0000011) | (opcode == 7'b0010011) | (opcode == 7'b0100011) ) begin 
        sel_bw_imm_rs2 = 0;
    end
    else begin
        sel_bw_imm_rs2 = 1;
    end
end

// I_type generating read signal to give data memory in order to read data 
// from particular memory location

always @(*) begin
    // opcode = 3 for load operations
    if ( (opcode == 7'b0000011) ) begin
        dmem_read_en = 1'b1;
    end
    else begin
        dmem_read_en = 1'b0;
    end
end

// I_type write back selection signal

always @(*) begin
    // opcode = 3 - 7 bits
    if( (opcode == 7'b0000011) ) begin
        wr_back_sel = 1'b0;
    end
    else begin
        wr_back_sel = 1'b1;
    end
end

// S_type format for choosing operation

// Different always blocks for selectiing alu operation will through error - so use same block for all instructions in
// selecting type of operation 

// always @(*) begin
//     // opcode = 35
//     case (opcode)
//         // opcode = 35
//         7'b0100011 : begin
//             case (func3) // 0, 1, 2
//                 3'b000: alu_op = add; // address calculation - store byte
//                 3'b001: alu_op = add; // address calculation - store half word
//                 3'b010: alu_op = add; // address calculation - store word
//                 default: alu_op = add;
//             endcase
//         end
//         default: alu_op = add;
//     endcase
// end

// generating write enable signal

always @(*) begin
    case (opcode)
        7'b0100011 : dmem_write_en = 1'b1;
        default: dmem_write_en = 1'b0; 
    endcase
end

    
endmodule