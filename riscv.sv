/*
1. riscvpipelined module combines datapath, control unit, and hazard unit
2. top module will combine the riscvpipelined with instruction and data memories
*/

module riscv (input logic clk, clr,
                        // inputs from Instruction and Data memories
                        input logic [31:0] RD_instr, RD_data,

                        // outputs to Instruction and Data memories
                        output logic [31:0] PCF,
                        output logic [31:0] ALUResultM, WriteDataM,
                        output logic MemWriteM);

    // control signals
    logic RegWriteD;
    logic [1:0] ResultSrcD;
    logic MemWriteD;
    logic JumpD;
    logic BranchD;
    logic [2:0] ALUControlD;
    logic ALUSrcD;
    logic [1:0] ImmSrcD;

    logic [31:0] InstrD; // 
    logic ResultSrcE_zero;

    // Hazard unit wires
    logic StallF;
    logic StallD, FlushD;
    logic FlushE;
    logic [1:0] ForwardAE, ForwardBE;
    logic PCSrcE;

    logic [4:0] Rs1D, Rs2D;
    logic [4:0] Rs1E, Rs2E, RdE;
    logic ResultSrcE;
    logic [4:0] RdM, RdW;
    logic RegWriteM, RegWriteW;

    // ----------------------------

    controller c(
        .op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7b5(InstrD[30]),
        
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .ImmSrcD(ImmSrcD)
    );

    datapath dp(.clk(clk), .clr(clr),

                // Control signals
                .RegWriteD(RegWriteD),
                .ResultSrcD(ResultSrcD),
                .MemWriteD(MemWriteD),
                .JumpD(JumpD),
                .BranchD(BranchD),
                .ALUControlD(ALUControlD),
                .ALUSrcD(ALUSrcD),
                .ImmSrcD(ImmSrcD),

                // inputs from Hazard unit
                .StallF(StallF), .StallD(StallD), .FlushD(FlushD), .FlushE(FlushE),
                .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),

                .RD_instr(RD_instr), .RD_data(RD_data),

                // outputs to Instruction and Data memories
                .PCF(PCF),
                .ALUResultM(ALUResultM), .WriteDataM(WriteDataM),
					 .MemWriteM(MemWriteM),
                .InstrD(InstrD),

                // outputs to Hazard unit
                .Rs1D(Rs1D), .Rs2D(Rs2D),
                .Rs1E(Rs1E), .Rs2E(Rs2E),
                .PCSrcE(PCSrcE), .ResultSrcE_zero(ResultSrcE_zero),
                .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
                .RdE(RdE),
                .RdM(RdM),
                .RdW(RdW));

    hazard hu(
        .Rs1D(Rs1D), .Rs2D(Rs2D),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .PCSrcE(PCSrcE),
        .ResultSrcE_zero(ResultSrcE_zero),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),

        .StallF(StallF),
        .StallD(StallD), .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );
    
endmodule