`timescale 1ns/1ns

module NOAA_Testbench();
  
  // Ports of __NOAA_Module__
  reg      CLK, RESET, MODE;
  reg      [11:0] TN;
  wire     SAMPLE, DONE;
  wire     [11:0] AVG_SD;
  
  
  // Integers for checking test data
  integer  dataFile;
  integer  scanFile;
  
  // Dummy registers for building test stimulus
  reg      mode;
  reg      [11:0] newInput;
  reg      [11:0] expectedOutput;
  
  
  // Checking for availability of test data
  initial begin
    $display("Initiating NOAA IoT Motes Module Testing Phase!! Good Luck!!");
    // Change the test data filename below
    dataFile = $fopen("NOAA_Test_Data_30.txt", "r");
    if (dataFile == 0)
      begin
        $display("Data file does not exist");
        $stop;
      end
  end

  initial begin
    CLK = 0;
    RESET = 1; 
  end
    
  initial begin
    #50
    RESET = 0;
  end
    
  always #10 CLK = ~CLK; 
  
  always begin
    #60
    scanFile = $fscanf(dataFile, "%d %d %d\n", newInput, mode, expectedOutput);
    if (!$feof(dataFile)) 
      begin
        TN = newInput;
        MODE = mode;
      end
  end
    
  // Comparison of NOAA IoT Mote Module output with expected output
  always @(posedge CLK) begin
    if (DONE) begin
      $strobe("Reset: %d TN: %5d MODE: %d DONE: %d AVG_OR_SD: %5d expectedOutput: %5d", RESET, TN, MODE, DONE, AVG_SD, expectedOutput);
      if (AVG_SD != expectedOutput) begin
        $error("WRONG OUTPUT GENERATED!! PLEASE FIX YOUR DESIGN!!");
        $stop;
      end
      if (scanFile == -1) begin
        $display("NOAA IoT Motes MODULE PASSED ALL TESTS!! CONGRATULATIONS!!");
        $stop;
      end
    end
  end
        
  __NOAA_Module__ IoT_Motes(
                  .CLK(CLK),
                  .RESET(RESET),
                  .MODE(MODE),
                  .TN(TN),
                  .SAMPLE(SAMPLE),
                  .DONE(DONE),
                  .AVG_SD(AVG_SD)
                  );
endmodule                    
