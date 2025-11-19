module __NOAA_Module__( CLK, RESET, MODE, TN, SAMPLE, DONE, AVG_SD );

    // ports
    input CLK, RESET, MODE;
    input [ 11:0 ] TN;

    output SAMPLE, DONE;
    output [ 11:0 ] AVG_SD;

    // constants / labels
    localparam TEMP_WIDTH       = 12;
    localparam N_SAMPLES        = 14;
    localparam MAX_IDX          = 4'b1101;
    localparam SUM_SQRD_WIDTH   = 28;

    localparam INIT_STDEV = 12'b010000000000;

    // internal signals
    wire                                mode;
    wire [ 3:0 ]                        idx_reg;
    wire [ 3:0 ]                        num_smpls;
    wire [ N_SAMPLES-1:0 ]              temp_reg_ENs;
    wire [ N_SAMPLES*TEMP_WIDTH-1:0 ]   temps;
    reg  [ 15:0 ]                       sum; // hold from 0 to 1400
    wire [ TEMP_WIDTH-1:0 ]             avg;
    reg  [ SUM_SQRD_WIDTH-1:0 ]         sum_sqrd; // 0 to (100^2)*14
    wire [ SUM_SQRD_WIDTH-1:0 ]         var;
    wire [ TEMP_WIDTH-1:0 ]             stdev;
    wire [ TEMP_WIDTH-1:0 ]             stdev_q;
    wire [ TEMP_WIDTH-1:0 ]             avg_sd;

    integer                             i;

    // input latches
    dff     #( .DATA_WIDTH( 1 ), .RESET_VAL( 0 ) )
     mode_ff ( .clk( CLK    ),
               .rst( RESET  ),
               .en(  1'b1   ),
               .d(   MODE   ),
               .q(   mode   ) );

    // counter ( count valid samples until steady state of N_samples )
    counter_stop #( .DATA_WIDTH( 4 ), .MAX_VAL( N_SAMPLES ) )
        smpl_cntr ( .clk( CLK       ),
                    .rst( RESET     ),
                    .out( num_smpls ) );

    // counter ( which slot to put sample in )
    counter     #(  .DATA_WIDTH( 4 ), .MAX_VAL( MAX_IDX ) )
        idx_cntr (  .clk( CLK        ),
                    .rst( RESET      ),
                    .out( idx_reg    ) );

    // decoder ( assert enable for correct reg )
    decoder #( .DATA_WIDTH( 4 ), .PORTS( N_SAMPLES ) )
        dcdr ( .count( idx_reg      ),
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
    assign avg = ( num_smpls == 0 ) ? 0 : ( sum / num_smpls );

    // square all temps 
    always @(*) begin
        sum_sqrd = 0;
        for (i = 0; i < N_SAMPLES; i = i + 1)
            sum_sqrd = sum_sqrd 
                     + temps[ i*TEMP_WIDTH +: TEMP_WIDTH ] 
                     * temps[ i*TEMP_WIDTH +: TEMP_WIDTH ];
    end
    
    // find the variance 
    assign var = ( num_smpls == 0 ) ? 0 : sum_sqrd / num_smpls - avg * avg;

    // compute the standard deviation
    assign stdev = ( stdev_q == 0 ) ? 0 : ( ( var / stdev_q ) + stdev_q ) / 2;

    // store the last read standard deviation
    dff     #( .DATA_WIDTH( TEMP_WIDTH ), .RESET_VAL( INIT_STDEV ) )
     stdev_ff( .clk( CLK        ),
               .rst( RESET      ),
               .en(  mode       ),
               .d(   stdev      ),
               .q(   stdev_q    ) );

    // output selection
    mux2_1 #( TEMP_WIDTH )
     out_mux( .s(  mode     ),
              .d0( avg      ),
              .d1( stdev    ),
              .q(  avg_sd   ) );

    // output latches
    assign SAMPLE = DONE;

    dff     #( .DATA_WIDTH( 1 ) )
     done_ff ( .clk( CLK            ),
               .rst( RESET          ),
               .en(  1'b1           ),
               .d(   num_smpls >= 1 ),
               .q(   DONE           ) );

    dff    #( .DATA_WIDTH( TEMP_WIDTH ) )
     out_ff ( .clk( CLK    ),
              .rst( RESET  ),
              .en(  1'b1   ),
              .d(   avg_sd ),
              .q(   AVG_SD ) );


endmodule
