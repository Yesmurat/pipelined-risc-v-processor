module imem (input logic [31:0] a,
             output logic [31:0] rd);
    
    logic [31:0] RAM[63:0];

    initial
        $readmemh("C:/intelFPGA_lite/riscvtest.txt", RAM, 0, 2);

    assign rd = RAM[a[31:2]]; // word aligned
endmodule // Instruction memory