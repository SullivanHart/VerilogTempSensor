module counter_stop #( parameter DATA_WIDTH = 10, 
                       parameter MAX_VAL    = 8 )
                     ( clk, rst, out );

    input wire clk, rst;
    output reg [ DATA_WIDTH - 1:0 ] out;

    always @( posedge clk or posedge rst ) begin
        if ( rst )
            out <= {DATA_WIDTH{1'b0}}; // reset to 0
        else if ( out < MAX_VAL )
            out <= out + 1'b1; // add 1
    end


endmodule