module decoder #( parameter DATA_WIDTH = 4,
                  parameter PORTS      = 14 )
                  ( count, out );

    input  wire [ DATA_WIDTH-1:0] count;
    output wire [ PORTS-1:0 ] out;

    genvar i;
    generate
        for (i = 0; i < PORTS; i = i + 1) begin : gen_decode
            assign out[i] = (count == i[ DATA_WIDTH-1:0 ] );
        end
    endgenerate


endmodule
