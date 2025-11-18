module register #( parameter DATA_WIDTH = 12,
                   parameter N          = 14 )
                  ( clk, rst, enables, in_smpl, out_smpls );

    input wire                      clk, rst;
    input wire  [ N-1:0 ]           enables;
    input wire  [ DATA_WIDTH-1:0 ]  in_smpl; 

    // 14 registers of 12 bits each
    output reg [ N*DATA_WIDTH-1:0 ]  out_smpls;

    genvar i;
    generate
        for ( i = 0; i < N; i = i + 1 ) begin : sample_regs
            always @(posedge clk or posedge rst ) begin
                if ( rst )
                    out_smpls[ i * DATA_WIDTH +: DATA_WIDTH ] 
                        <= 12'b010000000000; // reset to 32 F
                else if ( enables[ i ] )
                    out_smpls[ i * DATA_WIDTH +: DATA_WIDTH ] 
                        <= in_smpl;
            end
        end
endgenerate

endmodule
