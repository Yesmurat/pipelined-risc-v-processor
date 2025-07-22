module maindec (input logic [6:0] op,
                output logic [1:0] ResultSrcD,
                output logic MemWriteD,
                output logic BranchD, ALUSrcD,
                output logic RegWriteD, JumpD,
                output logic [1:0] ImmSrcD,
                output logic [1:0] ALUOp);

    logic [10:0] controls;

    assign {RegWriteD, ImmSrcD, ALUSrcD, MemWriteD,
            ResultSrcD, BranchD, ALUOp, JumpD} = controls;

    always_comb
        case (op)
        // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
            7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
            7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
            7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type
            7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
            default:    controls = 11'b0_00_0_0_00_0_00_0; // ???
        endcase
    
endmodule