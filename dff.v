module dff  #( parameter DATA_WIDTH = 12,
               parameter RESET_VAL  = {DATA_WIDTH{1'b0}} )
             ( clk, rst, en, d, q );

    // ports
    input                           clk, rst, en;
    input      [ DATA_WIDTH-1:0 ]   d; 

    output reg [ DATA_WIDTH-1:0 ]   q;

    // update output on positive edge
    always @ ( posedge clk or posedge rst ) begin
        if ( rst )
            q <= RESET_VAL;
        else if (en)
            q <= d;
    end

endmodule
