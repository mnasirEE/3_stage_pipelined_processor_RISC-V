module imm_gene (
    input logic [31:0] inst,
    output logic [31:0] imm
);

logic [31:0] imm_out_i;
logic [31:0] imm_out_s;

logic [6:0] opcode;
assign opcode = inst[6:0];

// for i_type
// logic [11:0] imm;

// for s_type
logic [11:0] imm_s;
logic [4:0] imm1;
logic [6:0] imm2;

// assign imm1 = inst[11:7];
// assign imm2 = inst[31:25];
// assign imm_s[4:0] = imm1;
// assign imm_s[11:5] = imm2;

always @(*) begin
    case (opcode)
    // i_type
        7'b0000011 : imm = inst[31:20];
        7'b0010011 : imm = inst[31:20];
    // s_type
        // 7'b0100011 : imm1 = inst[11:7];
        // 7'b0100011 : imm2 = inst[31:25];
        default:  imm = inst[31:20]; 
    endcase
end

always @(*) begin
    if (opcode == 7'b0100011) begin
        imm1 = inst[11:7];
        imm2 = inst[31:25];
    end
end

assign imm_out_i[11:0] = imm;
assign imm_s[4:0] = imm1;
assign imm_s[11:5] = imm2;
assign imm_out_s[11:0] = imm_s;

// assign imm_out_i[11:0] = imm;
// sign extension
always @(*) begin
    if ( imm[11] == 0) begin
        imm_out_i[31:12] = 20'h00000;
    end
    else //begin
        imm_out_i[31:12] = 20'hFFFFF;
    // end
end


always @(*) begin
    if (imm_s[0] == 0) begin
        imm_out_s[31:12] = 20'h00000;
    end
    else begin
        imm_out_s[31:12] = 20'hFFFFF;
    end
end

always @(*) begin
    case (opcode)
    7'b0000011: imm = imm_out_i;
    7'b0010011 : imm = imm_out_i;
    7'b0100011 : imm = imm_out_s;
    // default: 
endcase
    
end


     
endmodule

// imm_gene immg1 (.inst(), .imm_out());