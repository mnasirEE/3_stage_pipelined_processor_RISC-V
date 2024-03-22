module mux_2x1 #(parameter data_width = 32)
   ( input logic [data_width - 1:0] in0, in1,
   input logic sel,
   output logic [data_width-1:0] mux_out

);

assign mux_out = sel ? in1 : in0 ; // if sel = 1 mux_out = in1, else mux_out = in0
    
endmodule

// mux_2x1 m1 (.in0(), .in1(), .sel(), .mux_out());