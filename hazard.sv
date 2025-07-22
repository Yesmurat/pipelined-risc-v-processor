module hazard (input logic [4:0] Rs1D, Rs2D,
                input logic [4:0] Rs1E, Rs2E, RdE,
                input logic PCSrcE, 
                input logic ResultSrcE_zero,
                input logic [4:0] RdM,
                input logic RegWriteM,
                input logic [4:0] RdW,
                input logic RegWriteW,

                output logic StallF,
                output logic StallD, FlushD,
                output logic FlushE,
                output logic [1:0] ForwardAE, ForwardBE
);

    logic lwStall;

    always_comb begin 

        // Forward to solve data hazards when possible
        if ( ( (Rs1E == RdM) && RegWriteM ) && (Rs1E != 0) ) begin
            ForwardAE = 2'b10;
        end else if ( ((Rs1E == RdW) && RegWriteW) && (Rs1E != 0) ) begin
            ForwardAE = 2'b01;
        end else ForwardAE = 2'b00;

        if ( ( (Rs2E == RdM) && RegWriteM ) && (Rs2E != 0) ) begin
            ForwardBE = 2'b10;
        end else if ( ((Rs2E == RdW) && RegWriteW) && (Rs2E != 0) ) begin
            ForwardBE = 2'b01;
        end else ForwardBE = 2'b00;
    end

    // Stall when a load hazard occurs
    assign lwStall = ResultSrcE_zero & ( (Rs1D == RdE) | (Rs2D == RdE) );
    assign StallF = lwStall ? 1'b1 : 1'b0;
    assign StallD = lwStall ? 1'b1 : 1'b0;

    // Flush when a branch is taken or a load introduces a bubble
    assign FlushD = PCSrcE ? 1'b1 : 1'b0;
    assign FlushE = (lwStall | PCSrcE) ? 1'b1 : 1'b0;
    
endmodule