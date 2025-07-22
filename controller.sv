module controller (input logic [6:0] op,
                   input logic [2:0] funct3,
                   input logic funct7b5,

                   output logic RegWriteD,
                   output logic [1:0] ResultSrcD,
                   output logic MemWriteD,
                   output logic JumpD,
                   output logic BranchD,
                   output logic [2:0] ALUControlD,
                   output logic ALUSrcD,
                   output logic [1:0] ImmSrcD);

    logic [1:0] ALUOp;

    maindec md(
        .op(op),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .BranchD(BranchD),
        .ALUSrcD(ALUSrcD),
        .RegWriteD(RegWriteD),
        .JumpD(JumpD),
        .ImmSrcD(ImmSrcD),
        .ALUOp(ALUOp)
    );

    aludec ad(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUOp),
        .ALUControl(ALUControlD)
    );
    
endmodule
