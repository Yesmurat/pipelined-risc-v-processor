/*
Fetch stage: PCF, RD_instr
IF/ID stage: InstrD, PCD, PCPlus4D
ID/EX stage: RD1, RD2, ImmExtD, all control signals decoded
EX/MEM stage: ALUResultE, WriteDataE, PCTargetE, control signals
MEM/WB stage: RD_data, ALUResultM, RdW, control signals
*/


module datapath (input logic clk, clr,
                // Control signals
                input logic RegWriteD,
                input logic [1:0] ResultSrcD,
                input logic MemWriteD,
                input logic JumpD,
                input logic BranchD,
                input logic [2:0] ALUControlD,
                input logic ALUSrcD,
                input logic [1:0] ImmSrcD,
                
                // input signals from Hazard Unit
                input logic StallF, StallD, FlushD, FlushE,
                input logic [1:0] ForwardAE, ForwardBE,

                input logic [31:0] RD_instr, RD_data, // outputs from Instruction Memory and Data Memory

                // outputs
                output logic [31:0] PCF, // input for Instruction Memory
                output logic [31:0] ALUResultM, WriteDataM, // inputs to Data Memory
                output logic MemWriteM, // we signal for data memory
                output logic [31:0] InstrD, // input to Control Unit

                // outputs to Hazard Unit
                output logic [4:0] Rs1D, Rs2D, // outputs from ID stage
                output logic [4:0] Rs1E, Rs2E,
                output logic [4:0] RdE, // outputs from EX stage
                output logic PCSrcE, ResultSrcE_zero, RegWriteM, RegWriteW,
                output logic [4:0] RdM, // output from MEM stage
                output logic [4:0] RdW // output from WB stage

);  
    // -----------------------------------------------------------------//
    // PC mux
    logic [31:0] PCPlus4F, PCTargetE, PCF_new;
    logic PCSrcE_int;
    logic [31:0] PCF_int;
    assign PCSrcE = PCSrcE_int;
    assign PCF = PCF_int;

    mux2 pcmux(
        .d0(PCPlus4F),
        .d1(PCTargetE),
        .s(PCSrcE_int),
        .y(PCF_new)
    );

    // -----------------------------------------------------------------//
    // Instruction Fetch (IF) stage
    IFregister ifreg(
        .clk(clk),
        .en(~StallF),
        .clr(clr),
        .d(PCF_new),
        .q(PCF_int)
    );

    adder pcplus4(
        .a(PCF_int),
        .b(32'd4),
        .y(PCPlus4F)
    );

    // ----------------------------------------------------------------//
    // Instruction Decode (ID) stage
    logic [31:0] PCD, PCPlus4D;
    logic [31:0] RD1, RD2;
    logic [31:0] ResultW;
    logic [31:0] ImmExtD;
    logic [4:0] RdD;

    logic [31:0] InstrD_int;
    assign InstrD = InstrD_int;

    logic [4:0] Rs1D_int, Rs2D_int;
    assign Rs1D = Rs1D_int;
    assign Rs2D = Rs2D_int;

    assign Rs1D_int = InstrD_int[19:15];
    assign Rs2D_int = InstrD_int[24:20];
    assign RdD = InstrD_int[11:7];

    IFIDregister ifidreg(
        .clk(clk),
        .clr(FlushD | clr),
        .en(~StallD),
        .RD_instr(RD_instr), .PCF(PCF_int), .PCPlus4F(PCPlus4F),
        .InstrD(InstrD_int), .PCD(PCD), .PCPlus4D(PCPlus4D)
    );
	 
	logic RegWriteW_int;
    assign RegWriteW = RegWriteW_int;

    regfile rf(
        .clk(clk), .we3(RegWriteW_int),
        .a1(Rs1D_int), .a2(Rs2D_int), .a3(RdW),
        .wd3(ResultW), .rd1(RD1), .rd2(RD2)
    );

    extend ext(
        .instr(InstrD_int),
        .immsrc(ImmSrcD),
        .immext(ImmExtD)
    );

    // ----------------------------------------------------------------//
    // Execute (EX) stage
    logic [31:0] RD1E, RD2E, PCE;
    logic [31:0] ImmExtE;
    logic [31:0] PCPlus4E;

    logic [31:0] SrcAE, SrcBE;
    logic [31:0] WriteDataE;
    logic [31:0] ALUResultE;

    logic RegWriteE;
    logic [1:0] ResultSrcE;
    logic MemWriteE, JumpE, BranchE;
    logic [2:0] ALUControlE;
    logic ALUSrcE;
    logic ZeroE;

    IDEXregister idexreg(
        .clk(clk), .clr(FlushE | clr),
        // ID stage control signals
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),

        // EX stage control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),

        // datapath inputs & outputs
        .RD1(RD1), .RD2(RD2), .PCD(PCD),
        .Rs1D(Rs1D_int), .Rs2D(Rs2D_int), .RdD(RdD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),

        .RD1E(RD1E), .RD2E(RD2E), .PCE(PCE),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E)
    );

    assign PCSrcE_int = (BranchE & ZeroE) | JumpE;
    assign ResultSrcE_zero = ResultSrcE[0];
	 
	logic [31:0] ALUResultM_int;
    assign ALUResultM_int = ALUResultM;

    mux3 SrcAEmux(
        .d0(RD1E), .d1(ResultW), .d2(ALUResultM_int), // inputs
        .s(ForwardAE), // select signal
        .y(SrcAE) // output
    );

    mux3 WriteDataEmux(
        .d0(RD2E), .d1(ResultW), .d2(ALUResultM_int), // inputs
        .s(ForwardBE), // select signal
        .y(WriteDataE) // output
    );

    mux2 SrcBEmux(
        .d0(WriteDataE), .d1(ImmExtE), // inputs
        .s(ALUSrcE), // select signal
        .y(SrcBE) // output
    );

    adder add(
        .a(PCE), .b(ImmExtE), // inputs
        .y(PCTargetE) // output
    );

    alu alu(
        .d0(SrcAE), .d1(SrcBE), //  inputs
        .s(ALUControlE), // operation control signal
        .y(ALUResultE), // output
        .Zero(ZeroE) // zero signal
    );

    // --------------------------------------------------------------//
    // Memory write (MEM) stage
    logic [31:0] PCPlus4M;

    logic RegWriteM_int;
    assign RegWriteM = RegWriteM_int;
    
    logic [1:0] ResultSrcM;

    EXMEMregister exmemreg(
        .clk(clk), .clr(clr),
        // EX stage control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),

        // MEM stage control signals
        .RegWriteM(RegWriteM_int),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),

        // datapath inputs & outputs
        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),

        .ALUResultM(ALUResultM), // output to Data Memory
        .WriteDataM(WriteDataM),
        .RdM(RdM),
        .PCPlus4M(PCPlus4M)
    );

    // -------------------------------------------------------------//
    // Register file writeback (WB) stage
    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [31:0] PCPlus4W;

    logic [1:0] ResultSrcW;

    MEMWBregister wbreg(
        .clk(clk), .clr(clr),
        // MEM stage control signals
        .RegWriteM(RegWriteM_int),
        .ResultSrcM(ResultSrcM),

        .RegWriteW(RegWriteW_int),
        .ResultSrcW(ResultSrcW),

        // datapath inputs & outputs
        .ALUResultM(ALUResultM_int),
        .RD(RD_data),
        .RdM(RdM),
        .PCPlus4M(PCPlus4M),

        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW),
        .PCPlus4W(PCPlus4W)
    );

    mux3 ResultWmux(
        .d0(ALUResultW), .d1(ReadDataW), .d2(PCPlus4W), // inputs
        .s(ResultSrcW), // select signal
        .y(ResultW) // output
    );

endmodule