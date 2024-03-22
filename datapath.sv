module datapath #( parameter addr_data_width = 32)
    (output logic [addr_data_width - 1:0] PC,
    input logic reset1, clk1,
    output logic [addr_data_width - 1:0] alu_out,
    output logic [addr_data_width - 1:0] wr_back_data

);

// fetch 

always_ff @(posedge clk1, posedge reset1)
    if (reset1)
        PC <= 0;
    else
        PC <= PC + 1;

logic [addr_data_width -1:0] instr_out;

instruction_memory imem (.address(PC),
                         .instruction(instr_out));

// reg [31:0] inst_mem [0:511];

// assign inst_mem[0] = 32'h004182b3;
// assign inst_mem[1] = 32'h40418333;
// assign inst_mem[2] = 32'h004193b3;
// assign inst_mem[3] = 32'h0041c433;
// assign inst_mem[4] = 32'h0041d4b3;
// assign inst_mem[5] = 32'h0041e533;
// assign inst_mem[6] = 32'h0041f5b3;

// initial begin
//     $readmemh("read_instructions.txt", inst_mem);
// end

// assign instr_out = inst_mem[PC];
// assign instr_out = 32'h004182b3;

logic [3:0] alu_operation;
logic wr_enable;
logic sel_imm;
logic read_en;
logic wrb_en;
logic write_en;
controller c1 (.instruction(instr_out), 
                .alu_op(alu_operation), 
                .regfile_write_enable(wr_enable),
                .sel_bw_imm_rs2(sel_imm),
                .dmem_read_en(read_en),
                .wr_back_sel(wrb_en),
                .dmem_write_en(write_en));

// decode

logic [4:0] addr_dr, addr_rs1, addr_rs2;
logic [addr_data_width - 1:0] rs1_data, rs2_data;

assign addr_dr = instr_out[11:7];
assign addr_rs1 = instr_out[19:15];
assign addr_rs2 = instr_out[24:20];

reg_file r1 (.wr_addr(addr_dr), 
            .r_addr1(addr_rs1), 
            .r_addr2(addr_rs2), 
            .wr_data (wr_back_data), 
            .write_back_en(wr_enable),
            .clk(clk1),
            .r_data1 (rs1_data), 
            .r_data2 (rs2_data));

logic [31:0] immediate ;

imm_gene immg1 (.inst(instr_out), 
                .imm(immediate));

logic [31:0] mux_out1; 
mux_2x1 m1 (.in0(immediate), 
            .in1(rs2_data), 
            .sel(sel_imm), 
            .mux_out(mux_out1));
// execute

alu a1 (.operand_a(rs1_data), 
        .operand_b(mux_out1), 
        .select_op(alu_operation), 
        .result_out (alu_out));

// data memory 

logic [31:0] rmem_data;

data_memory dm1 (.clk(clk1),
             .wr_en(write_en),
             .r_en(read_en), 
             .data_in(rs2_data), 
             .addr(alu_out), 
             .data_out(rmem_data));
// write back
// logic [31:0] wr_back_data;
mux_2x1 m2 (.in0(rmem_data), 
            .in1(alu_out), 
            .sel(wrb_en), 
            .mux_out(wr_back_data));


// write back
// reg_file r2 ((.wr_addr) addr_dr, (.r_addr1) addr_rs1, (.r_addr2) addr_rs2, (.wr_data) alu_out, (.r_data1) rs1_data, (.r_data2) rs2_data);

    
endmodule