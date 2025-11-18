module __NOAA_Module__( CLK, RESET, MODE, TN, SAMPLE, DONE, AVG_SD );

    // ports
    input CLK, RESET, MODE;
    input [ 11:0 ] TN;

    output SAMPLE, DONE;
    output [ 11:0 ] AVG_SD;

    // constants / labels
    localparam AVG = 1'b0;
    localparam SD  = 1'b1;

    localparam TEMP_WIDTH = 12;
    localparam N_SAMPLES  = 14;

    // internal signals
    wire [ 3:0 ]                        cntr_val;
    wire [ N_SAMPLES-1:0 ]              temp_reg_ENs;
    wire [ N_SAMPLES*TEMP_WIDTH-1:0 ]   temps;
    reg  [ 15:0 ]                       sum; // hold from 0 to 1400
    wire [ TEMP_WIDTH-1:0 ]             avg;

    integer                             i;

    // counter ( which slot to put sample in )
    counter #( .DATA_WIDTH( 4 ), .MAX_VAL( N_SAMPLES - 1 ) )
        cntr ( .clk( CLK        ),
               .rst( RESET      ),
               .out( cntr_val   ) );

    // decoder ( assert enable for correct reg )
    decoder #( .DATA_WIDTH( 4 ), .PORTS( N_SAMPLES ) )
        dcdr ( .count( cntr_val     ),
               .out(   temp_reg_ENs ) );

    // register ( hold the samples in a FIFO-buffer )
    register #( .DATA_WIDTH( TEMP_WIDTH ), .N( N_SAMPLES ) )
        rgstr ( .clk(       CLK             ),
                .rst(       RESET           ),
                .enables(   temp_reg_ENs    ),
                .in_smpl(   TN              ),
                .out_smpls( temps           ) );

    // sum all temps 
    always @(*) begin
        sum = 0;
        for (i = 0; i < N_SAMPLES; i = i + 1)
            sum = sum + temps[ i*TEMP_WIDTH +: TEMP_WIDTH ];
    end

    // find the average 
    assign avg = sum / N_SAMPLES;

    // output appropriate signal
    mux2_1 #( TEMP_WIDTH )
     out_mux( .s(  MODE     ),
              .d0( avg      ),
              .d1( sd       ),
              .q(  AVG_SD   ) );


endmodule
