module dmem (input logic clk, we,
             input logic [31:0] a, wd,
             output logic [31:0] rd);

    logic [31:0] RAM[63:0];

    initial
        $readmemh("C:/intelFPGA_lite/riscvtest_dmem.txt", RAM, 0, 3);

    assign rd = RAM[a[31:2]]; // word-aligned

    always_ff @(posedge clk)
        if (we) RAM[a[31:2]] <= wd;
endmodule // Data memory