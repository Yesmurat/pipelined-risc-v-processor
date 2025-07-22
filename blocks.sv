module adder (input [31:0] a, b,
                output [31:0] y);

    assign y =  a + b;
    
endmodule // adder

module IFregister (input logic clk, en, clr,
                    input logic [31:0] d,
                    output logic [31:0] q);
    
    always_ff @(posedge clk)
        if (clr) begin
            q <= 32'b0;
        end
        else if (en) q <= d;
endmodule // IF stage register

module IFIDregister (input logic clk, clr, en,
                    input logic [31:0] RD_instr, PCF, PCPlus4F,
                    output logic [31:0] InstrD, PCD, PCPlus4D);
    
    always_ff @(posedge clk or posedge clr)
        if (clr) begin
            InstrD <= 32'b0;
            PCD <= 32'b0;
            PCPlus4D <= 32'b0;
        end
        else if (en) begin
            InstrD <= RD_instr;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
endmodule // ID stage register

module IDEXregister (input logic clk, clr,

                    // ID stage controls signals
                    input logic RegWriteD,
                    input logic [1:0] ResultSrcD,
                    input logic MemWriteD,
                    input logic JumpD,
                    input logic BranchD,
                    input logic [2:0] ALUControlD,
                    input logic ALUSrcD,

                    // EX stage controls signals
                    output logic RegWriteE,
                    output logic [1:0] ResultSrcE,
                    output logic MemWriteE,
                    output logic JumpE,
                    output logic BranchE,
                    output logic [2:0] ALUControlE,
                    output logic ALUSrcE,

                    // Datapath inputs & outputs
                    input logic [31:0] RD1, RD2, PCD,
                    input logic [4:0] Rs1D, Rs2D, RdD,
                    input logic [31:0] ImmExtD,
                    input logic [31:0] PCPlus4D,

                    output logic [31:0] RD1E, RD2E, PCE,
                    output logic [4:0] Rs1E, Rs2E, RdE,
                    output logic [31:0] ImmExtE,
                    output logic [31:0] PCPlus4E
);

    always_ff @(posedge clk) begin
        if (clr) begin

            RegWriteE <= 1'b0;
            ResultSrcE <= 2'b0;
            MemWriteE <= 1'b0;
            JumpE <= 1'b0;
            BranchE <= 1'b0;
            ALUControlE <= 3'b0;
            ALUSrcE <= 1'b0;

            RD1E <= 32'b0; RD2E <= 32'b0; PCE <= 32'b0;
            Rs1E <= 5'b0; Rs2E <= 5'b0; RdE <= 5'b0;
            ImmExtE <= 32'b0;
            PCPlus4E <= 32'b0;
        end else begin

            RegWriteE <= RegWriteD;
            ResultSrcE <= ResultSrcD;
            MemWriteE <= MemWriteD;
            JumpE <= JumpD;
            BranchE <= BranchD;
            ALUControlE <= ALUControlD;
            ALUSrcE <= ALUSrcD;

            RD1E <= RD1; RD2E <= RD2; PCE <= PCD;
            Rs1E <= Rs1D; Rs2E <= Rs2D; RdE <= RdD;
            ImmExtE <= ImmExtD;
            PCPlus4E <= PCPlus4D;
        end
    end
    
endmodule

module EXMEMregister (input logic clk, clr, // EX -> MEM

                    // EX stage control signals
                    input logic RegWriteE,
                    input logic [1:0] ResultSrcE,
                    input logic MemWriteE,

                    // MEM stage control signals
                    output logic RegWriteM,
                    output logic [1:0] ResultSrcM,
                    output logic MemWriteM,

                    // datapath inputs & outputs
                    input logic [31:0] ALUResultE,
                    input logic [31:0] WriteDataE,
                    input logic [4:0] RdE,
                    input logic [31:0] PCPlus4E,

                    output logic [31:0] ALUResultM,
                    output logic [31:0] WriteDataM,
                    output logic [4:0] RdM,
                    output logic [31:0] PCPlus4M
);

    always_ff @(posedge clk) begin

        if (clr) begin
            RegWriteM <= 1'b0;
            ResultSrcM <= 2'b0;
            MemWriteM <= 1'b0;

            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            RdM <= 5'b0;
            PCPlus4M <= 32'b0;
        end else begin
            RegWriteM <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM <= MemWriteE;

            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            RdM <= RdE;
            PCPlus4M <= PCPlus4E;
        end
    end
    
endmodule

module MEMWBregister (input logic clk, clr, // MEM -> WB

                    // MEM stage control signals
                    input logic RegWriteM,
                    input logic [1:0] ResultSrcM,

                    // WB stage signals
                    output logic RegWriteW,
                    output logic [1:0] ResultSrcW,

                    // datapath inputs & outputs
                    input logic [31:0] ALUResultM,
                    input logic [31:0] RD, // from Data Memory
                    input logic [4:0] RdM,
                    input logic [31:0] PCPlus4M,

                    output logic [31:0] ALUResultW,
                    output logic [31:0] ReadDataW,
                    output logic [4:0] RdW,
                    output logic [31:0] PCPlus4W
);

    always_ff @(posedge clk) begin
        if (clr) begin
            RegWriteW <= 1'b0;
            ResultSrcW <= 2'b0;

            ALUResultW <= 32'b0;
            ReadDataW <= 32'b0;
            RdW <= 5'b0;
            PCPlus4W <= 32'b0;
        end else begin
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;

            ALUResultW <= ALUResultM;
            ReadDataW <= RD;
            RdW <= RdM;
            PCPlus4W <= PCPlus4M;
        end
    end
    
endmodule

module mux2 (input logic [31:0] d0, d1,
              input logic s,
              output logic [31:0] y);
    
    assign y = s ? d1: d0;
endmodule // 2-to-1 multiplexer

module mux3 (input logic [31:0] d0, d1, d2,
                 input logic [1:0] s,
                 output logic [31:0] y);
    
    assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule // 3-to-1 mux

module regfile (input logic clk, we3,
                input logic [4:0] a1, a2, a3,
                input logic [31:0] wd3,

                output logic [31:0] rd1, rd2);

    logic [31:0] rf[31:0];

    // three ported register file
    // read two ports combinationally (A1/RD1, A2/RD2)
    // write third port on rising edge of clock (A3/WD3/WE3)
    // register 0 hardwired to 0

    // The register file is write-first and read occurs after write

    always_ff @(posedge clk)
        if (we3) rf[a3] <= wd3;

    always_comb begin
        // port 1
        if (we3 && (a3 == a1)) rd1 = wd3; // just-written data
        else if (a1 == 0) rd1 = 32'b0; // x0 is hardwired to zero
        else rd1 = rf[a1]; // stored data

        // port 2
        if (we3 && (a3 == a2)) rd2 = wd3;
        else if (a2 == 0) rd2 = 32'b0;
        else rd2 = rf[a2];
    end

endmodule // Register file

module alu (input logic [31:0] d0, d1,
            input logic [2:0] s,
            output logic [31:0] y,
            output logic Zero);

    always_comb begin
        case (s)
            3'b000: y = d0 + d1; // changed from d0 & d1
            3'b001: y = d0 - d1; // changed from d0 | d1
            3'b010: y = d0 + d1;
            3'b100: y = d0 & ~d1;
            3'b101: y = (d0 < d1) ? 32'b1 : 32'b0; // changed from d0 | ~d1
            3'b110: y = d0 - d1;
            3'b111: y = (d0 < d1) ? 32'b1 : 32'b0;
            default: y = 32'b0;
        endcase
    end

    assign Zero = (y == 32'bx);
    
endmodule

module extend (input logic [31:0] instr,
               input logic [1:0] immsrc,
               output logic [31:0] immext);

    always @(*)
        case (immsrc)
                    // I-type
            2'b00: immext = { {20{ instr[31] }}, instr[31:20] };
                    // S-type
            2'b01: immext = { {20{instr[31]} }, instr[31:25], instr[11:7] };
                    // B-type (branches)
            2'b10: immext = { {20{instr[31]} }, instr[7], instr[30:25], instr[11:8], 1'b0 };
                    // J-type (jal)
            2'b11: immext = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };

            default: immext = 32'bx; // undefined
        endcase
        
endmodule