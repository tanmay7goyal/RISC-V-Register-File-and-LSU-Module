`timescale 1ns/1ps

module fetch_tb();

    // Parameters
    parameter CLK_PERIOD = 10;

    // Inputs
    reg clk_i;
    reg rst_i;
    reg icache_valid_i;
    reg [15:0] icache_instr_i;
    reg fetch_valid_i;
    reg branch_valid_i;
    reg [15:0] fetch_branch_pc_i;
    reg [15:0] opcode_pc_i;

    // Outputs
    wire icache_rd_o;
    wire [15:0] icache_pc_o;
    wire instr_valid_o;
    wire [15:0] fetch_pc_o;
    wire [15:0] fetch_instr_o;

integer  i;  // Instantiate DUT
    fetch dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .branch_type_oi(branch_type_i),
        .icache_valid_i(icache_valid_i),
        .icache_instr_i(icache_instr_i),
        .icache_rd_o(icache_rd_o),
        .icache_pc_o(icache_pc_o),
        .fetch_valid_i(fetch_valid_i),
        .instr_valid_o(instr_valid_o),
        .fetch_pc_o(fetch_pc_o),
        .fetch_instr_o(fetch_instr_o),
        .branch_valid_i(branch_valid_i),
        .fetch_branch_pc_i(fetch_branch_pc_i),
        .opcode_pc_i(opcode_pc_i)
    );

    // Clock generation
    always begin
        clk_i = 1'b1;
        #(CLK_PERIOD/2);
        clk_i = 1'b0;
        #(CLK_PERIOD/2);
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_i = 1'b1;
        icache_valid_i = 0;
        icache_instr_i = 0;
        fetch_valid_i = 0;
        branch_valid_i = 0;
        fetch_branch_pc_i = 0;
        opcode_pc_i = 0;
        
        // Reset system
        #(CLK_PERIOD*2);
        rst_i = 1'b0;
        #(CLK_PERIOD);

        // Test Case 1: Basic sequential fetch
        $display("Test Case 1: Sequential fetch");
        fetch_valid_i = 1;
        icache_valid_i = 1;
        icache_instr_i = 16'hA55A;
        #(CLK_PERIOD);
        check_outputs("TC1-1", 16'h0000, 16'hA55A, 1'b1);
        
        
        icache_instr_i = 16'h5AA5;
        #(CLK_PERIOD);
        check_outputs("TC1-2", 16'h0002, 16'h5AA5, 1'b1);
        
        icache_instr_i = 16'h1234;
        #(CLK_PERIOD);
        check_outputs("TC1-3", 16'h0004, 16'h1234, 1'b1);

        // Test Case 2: Branch without prediction
        $display("\nTest Case 2: Branch without prediction");
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h1000;
        opcode_pc_i = 16'h0004; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h1200;
        opcode_pc_i = 16'h0006; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h1020;
        opcode_pc_i = 16'h0104; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h1002;
        opcode_pc_i = 16'h0008; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h1620;
        opcode_pc_i = 16'h0014; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h4000;
        opcode_pc_i = 16'h0044; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h2000;
        opcode_pc_i = 16'h0024; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h12a0;
        opcode_pc_i = 16'h0006; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h1290;
        opcode_pc_i = 16'h0016; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
    
        icache_instr_i = 16'hBEEF;
        #(CLK_PERIOD);
        check_outputs("TC2-1", 16'h1000, 16'hBEEF, 1'b1);
        
    
        icache_instr_i = 16'hDEAD;
        #(CLK_PERIOD);
        check_outputs("TC2-2", 16'h1002, 16'hDEAD, 1'b1);

        // Test Case 3: Branch prediction
        $display("\nTest Case 3: Branch prediction");
        // First train the predictor
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h2000;
        opcode_pc_i = 16'h1002; // Branch from this PC
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        // Now trigger the same branch again
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h3000; // This should be ignored due to prediction
        opcode_pc_i = 16'h1002;
        #(CLK_PERIOD);
        branch_valid_i = 0;
  
        icache_instr_i = 16'hCAFE;
        #(CLK_PERIOD);
        check_outputs("TC3-1", 16'h2000, 16'hCAFE, 1'b1);

        // Test Case 4: fifo replacement policy
        $display("\nTest Case 4: fifo replacement");
        // Fill the predictor table
        for ( i = 0; i < 8; i = i + 1) begin
            branch_valid_i = 1;
            fetch_branch_pc_i = 16'h4000 + (i * 16'h100);
            opcode_pc_i = 16'h3000 + (i * 16'h100);
            #(CLK_PERIOD);
        end
        branch_valid_i = 0;
        
        // Add one more to trigger replacement
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h8000;
        opcode_pc_i = 16'h7000;
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
        // Verify replacement by checking if we can still predict the most recent
        branch_valid_i = 1;
        fetch_branch_pc_i = 16'h9000; // Should be ignored
        opcode_pc_i = 16'h7000;
        #(CLK_PERIOD);
        branch_valid_i = 0;
        
      
        icache_instr_i = 16'hBABE;
        #(CLK_PERIOD);
        check_outputs("TC4-1", 16'h8000, 16'hBABE, 1'b1);

        // Test Case 5: Cache miss handling
        $display("\nTest Case 5: Cache miss handling");
        fetch_valid_i = 1;
        icache_valid_i = 0;
        #(CLK_PERIOD);
      check_outputs("TC5-1", 16'h8002, 16'hxxxx, 1'b0);
        
        // Cache responds
        icache_valid_i = 1;
       
        icache_instr_i = 16'hFACE;
        #(CLK_PERIOD);
        check_outputs("TC5-2", 16'h8002, 16'hFACE, 1'b1);

        $display("\nAll tests passed!");
        $finish;
    end

    // Helper task to check outputs
    task check_outputs;
        input [80:0] test_name;
        input [15:0] exp_pc;
        input [15:0] exp_instr;
        input exp_valid;
        
        begin
            if (fetch_pc_o !== exp_pc || fetch_instr_o !== exp_instr || instr_valid_o !== exp_valid) begin
                $display("ERROR @ %s: Expected (PC=%h, Instr=%h, Valid=%b), Got (PC=%h, Instr=%h, Valid=%b)",
                         test_name, exp_pc, exp_instr, exp_valid, 
                         fetch_pc_o, fetch_instr_o, instr_valid_o);
                $finish;
            end else begin
                $display("PASS @ %s: (PC=%h, Instr=%h, Valid=%b)", 
                         test_name, fetch_pc_o, fetch_instr_o, instr_valid_o);
            end
        end
    endtask

endmodule