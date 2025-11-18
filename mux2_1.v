module mux2_1 #( parameter DATA_WIDTH = 10 )
               ( d0, d1, s, q );

    // ports
    input                         s;
    input      [ DATA_WIDTH-1:0 ] d0, d1; 
    output reg [ DATA_WIDTH-1:0 ] q;

    // update output q on any signal change
    always @( d0, d1, s )
        if( s == 0 )
            q = d0;
        else
            q = d1;

endmodule
