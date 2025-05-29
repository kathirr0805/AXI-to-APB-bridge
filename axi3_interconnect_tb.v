module axi3_interconnect_tb;

    // Testbench signals
    reg ACLK;
    reg ARESETn;

    // Master 0 (RISC-V Processor)
    reg [31:0] M0_AWADDR;
    reg M0_AWVALID;
    wire M0_AWREADY;
    reg [3:0] M0_AWLEN;  // AXI3: 4 bits
    reg [2:0] M0_AWSIZE;
    reg [1:0] M0_AWBURST;
    reg [31:0] M0_WDATA;
    reg [3:0] M0_WSTRB;
    reg M0_WVALID;
    wire M0_WREADY;
    reg M0_WLAST;
    wire [1:0] M0_BRESP;
    wire M0_BVALID;
    reg M0_BREADY;

    // Master 1 (DMA)
    reg [31:0] M1_AWADDR;
    reg M1_AWVALID;
    wire M1_AWREADY;
    reg [3:0] M1_AWLEN;  // AXI3: 4 bits
    reg [2:0] M1_AWSIZE;
    reg [1:0] M1_AWBURST;
    reg [31:0] M1_WDATA;
    reg [3:0] M1_WSTRB;
    reg M1_WVALID;
    wire M1_WREADY;
    reg M1_WLAST;
    wire [1:0] M1_BRESP;
    wire M1_BVALID;
    reg M1_BREADY;

    // Slave 0 (Memory)
    wire [31:0] S0_AWADDR;
    wire S0_AWVALID;
    reg S0_AWREADY;
    wire [3:0] S0_AWLEN;  // AXI3: 4 bits
    wire [2:0] S0_AWSIZE;
    wire [1:0] S0_AWBURST;
    wire [31:0] S0_WDATA;
    wire [3:0] S0_WSTRB;
    wire S0_WVALID;
    reg S0_WREADY;
    wire S0_WLAST;
    reg [1:0] S0_BRESP;
    reg S0_BVALID;
    wire S0_BREADY;

    // Slave 1 (AXI-to-APB Bridge)
    wire [31:0] S1_AWADDR;
    wire S1_AWVALID;
    reg S1_AWREADY;
    wire [3:0] S1_AWLEN;  // AXI3: 4 bits
    wire [2:0] S1_AWSIZE;
    wire [1:0] S1_AWBURST;
    wire [31:0] S1_WDATA;
    wire [3:0] S1_WSTRB;
    wire S1_WVALID;
    reg S1_WREADY;
    wire S1_WLAST;
    reg [1:0] S1_BRESP;
    reg S1_BVALID;
    wire S1_BREADY;

    // Instantiate the DUT (AXI3 Interconnect)
    axi3_interconnect dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .M0_AWADDR(M0_AWADDR),
        .M0_AWVALID(M0_AWVALID),
        .M0_AWREADY(M0_AWREADY),
        .M0_AWLEN(M0_AWLEN),
        .M0_AWSIZE(M0_AWSIZE),
        .M0_AWBURST(M0_AWBURST),
        .M0_WDATA(M0_WDATA),
        .M0_WSTRB(M0_WSTRB),
        .M0_WVALID(M0_WVALID),
        .M0_WREADY(M0_WREADY),
        .M0_WLAST(M0_WLAST),
        .M0_BRESP(M0_BRESP),
        .M0_BVALID(M0_BVALID),
        .M0_BREADY(M0_BREADY),
        .M1_AWADDR(M1_AWADDR),
        .M1_AWVALID(M1_AWVALID),
        .M1_AWREADY(M1_AWREADY),
        .M1_AWLEN(M1_AWLEN),
        .M1_AWSIZE(M1_AWSIZE),
        .M1_AWBURST(M1_AWBURST),
        .M1_WDATA(M1_WDATA),
        .M1_WSTRB(M1_WSTRB),
        .M1_WVALID(M1_WVALID),
        .M1_WREADY(M1_WREADY),
        .M1_WLAST(M1_WLAST),
        .M1_BRESP(M1_BRESP),
        .M1_BVALID(M1_BVALID),
        .M1_BREADY(M1_BREADY),
        .S0_AWADDR(S0_AWADDR),
        .S0_AWVALID(S0_AWVALID),
        .S0_AWREADY(S0_AWREADY),
        .S0_AWLEN(S0_AWLEN),
        .S0_AWSIZE(S0_AWSIZE),
        .S0_AWBURST(S0_AWBURST),
        .S0_WDATA(S0_WDATA),
        .S0_WSTRB(S0_WSTRB),
        .S0_WVALID(S0_WVALID),
        .S0_WREADY(S0_WREADY),
        .S0_WLAST(S0_WLAST),
        .S0_BRESP(S0_BRESP),
        .S0_BVALID(S0_BVALID),
        .S0_BREADY(S0_BREADY),
        .S1_AWADDR(S1_AWADDR),
        .S1_AWVALID(S1_AWVALID),
        .S1_AWREADY(S1_AWREADY),
        .S1_AWLEN(S1_AWLEN),
        .S1_AWSIZE(S1_AWSIZE),
        .S1_AWBURST(S1_AWBURST),
        .S1_WDATA(S1_WDATA),
        .S1_WSTRB(S1_WSTRB),
        .S1_WVALID(S1_WVALID),
        .S1_WREADY(S1_WREADY),
        .S1_WLAST(S1_WLAST),
        .S1_BRESP(S1_BRESP),
        .S1_BVALID(S1_BVALID),
        .S1_BREADY(S1_BREADY)
    );

    // Clock generation
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK; // 100 MHz clock (10 ns period)
    end

    // Reset generation
    initial begin
        ARESETn = 0;
        #10 ARESETn = 1; // Release reset after 10 ns
    end

    // Slave 0 (Memory) model
    reg [31:0] memory [0:255]; // Simple memory model
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S0_AWREADY <= 0;
            S0_WREADY <= 0;
            S0_BVALID <= 0;
            S0_BRESP <= 2'b00;
        end else begin
            // Accept address
            if (S0_AWVALID && !S0_AWREADY) begin
                $display("Memory: Accepting address 0x%h at %0t ns", S0_AWADDR, $time);
                S0_AWREADY <= 1;
            end else begin
                S0_AWREADY <= 0;
            end

            // Accept data and store in memory
            if (S0_WVALID && !S0_WREADY) begin
                $display("Memory: Writing data 0x%h to address 0x%h at %0t ns", S0_WDATA, S0_AWADDR, $time);
                S0_WREADY <= 1;
                memory[S0_AWADDR[7:0]] <= S0_WDATA; // Store data (using lower 8 bits of address)
            end else begin
                S0_WREADY <= 0;
            end

            // Send response
            if (S0_WVALID && S0_WREADY) begin
                S0_BVALID <= 1;
                S0_BRESP <= 2'b00; // OKAY
                $display("Memory: Sending BRESP 0x%h at %0t ns", S0_BRESP, $time);
            end else if (S0_BVALID && S0_BREADY) begin
                S0_BVALID <= 0;
            end
        end
    end

    // Slave 1 (AXI-to-APB Bridge) model
    reg [31:0] peripheral_reg; // Simple register to mimic peripheral
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S1_AWREADY <= 0;
            S1_WREADY <= 0;
            S1_BVALID <= 0;
            S1_BRESP <= 2'b00;
            peripheral_reg <= 0;
        end else begin
            // Accept address
            if (S1_AWVALID && !S1_AWREADY) begin
                $display("AXI-to-APB Bridge: Accepting address 0x%h at %0t ns", S1_AWADDR, $time);
                S1_AWREADY <= 1;
            end else begin
                S1_AWREADY <= 0;
            end

            // Accept data and store in register
            if (S1_WVALID && !S1_WREADY) begin
                $display("AXI-to-APB Bridge: Writing data 0x%h to address 0x%h at %0t ns", S1_WDATA, S1_AWADDR, $time);
                S1_WREADY <= 1;
                peripheral_reg <= S1_WDATA;
            end else begin
                S1_WREADY <= 0;
            end

            // Send response
            if (S1_WVALID && S1_WREADY) begin
                S1_BVALID <= 1;
                S1_BRESP <= 2'b00; // OKAY
                $display("AXI-to-APB Bridge: Sending BRESP 0x%h at %0t ns", S1_BRESP, $time);
            end else if (S1_BVALID && S1_BREADY) begin
                S1_BVALID <= 0;
            end
        end
    end

    // Test stimulus
    initial begin
        // Initialize signals
        M0_AWADDR = 0;
        M0_AWVALID = 0;
        M0_AWLEN = 0;
        M0_AWSIZE = 3'b010; // 32-bit transfers
        M0_AWBURST = 2'b01; // INCR burst
        M0_WDATA = 0;
        M0_WSTRB = 0;
        M0_WVALID = 0;
        M0_WLAST = 0;
        M0_BREADY = 0;

        M1_AWADDR = 0;
        M1_AWVALID = 0;
        M1_AWLEN = 0;
        M1_AWSIZE = 3'b010; // 32-bit transfers
        M1_AWBURST = 2'b01; // INCR burst
        M1_WDATA = 0;
        M1_WSTRB = 0;
        M1_WVALID = 0;
        M1_WLAST = 0;
        M1_BREADY = 0;

        // Wait for reset to deassert
        wait (ARESETn == 1);
        #5;

        // Test 1: M0 writes to memory (0x0000_0000)
        $display("Test 1: M0 writes to memory at %0t ns", $time);
        M0_AWADDR = 32'h0000_0000;
        M0_AWVALID = 1;
        wait (M0_AWREADY);
        @(posedge ACLK);
        M0_AWVALID = 0;
        M0_WDATA = 32'hDEAD_BEEF;
        M0_WSTRB = 4'b1111;
        M0_WVALID = 1;
        M0_WLAST = 1; // Single-beat transaction
        wait (M0_WREADY);
        @(posedge ACLK);
        M0_WVALID = 0;
        M0_WLAST = 0;
        M0_BREADY = 1;
        wait (M0_BVALID);
        @(posedge ACLK);
        M0_BREADY = 0;
        $display("M0 BRESP: %b at %0t ns", M0_BRESP, $time);
        if (M0_BRESP == 2'b00) $display("Test 1 Passed: M0 write to memory successful at %0t ns", $time);

        #10;

        // Test 2: M1 writes to AXI-to-APB bridge (0x1000_0000)
        $display("Test 2: M1 writes to AXI-to-APB bridge at %0t ns", $time);
        M1_AWADDR = 32'h1000_0000;
        M1_AWVALID = 1;
        wait (M1_AWREADY);
        @(posedge ACLK);
        M1_AWVALID = 0;
        M1_WDATA = 32'hCAFE_1234;
        M1_WSTRB = 4'b1111;
        M1_WVALID = 1;
        M1_WLAST = 1; // Single-beat transaction
        wait (M1_WREADY);
        @(posedge ACLK);
        M1_WVALID = 0;
        M1_WLAST = 0;
        M1_BREADY = 1;
        wait (M1_BVALID);
        @(posedge ACLK);
        M1_BREADY = 0;
        $display("M1 BRESP: %b at %0t ns", M1_BRESP, $time);
        if (M1_BRESP == 2'b00) $display("Test 2 Passed: M1 write to AXI-to-APB bridge successful at %0t ns", $time);

        #10;

        // Test 3: Concurrent writes (M0 to memory, M1 to AXI-to-APB bridge)
        $display("Test 3: Concurrent writes (M0 to memory, M1 to AXI-to-APB bridge) at %0t ns", $time);
        fork
            begin // M0 write to memory
                M0_AWADDR = 32'h0000_0010;
                M0_AWVALID = 1;
                wait (M0_AWREADY);
                @(posedge ACLK);
                M0_AWVALID = 0;
                M0_WDATA = 32'h1234_5678;
                M0_WSTRB = 4'b1111;
                M0_WVALID = 1;
                M0_WLAST = 1;
                wait (M0_WREADY);
                @(posedge ACLK);
                M0_WVALID = 0;
                M0_WLAST = 0;
                M0_BREADY = 1;
                wait (M0_BVALID);
                @(posedge ACLK);
                M0_BREADY = 0;
                $display("M0 BRESP: %b at %0t ns", M0_BRESP, $time);
                if (M0_BRESP == 2'b00) $display("Test 3 M0 Passed: M0 write to memory successful at %0t ns", $time);
            end
            begin // M1 write to AXI-to-APB bridge
                M1_AWADDR = 32'h1000_0010;
                M1_AWVALID = 1;
                wait (M1_AWREADY);
                @(posedge ACLK);
                M1_AWVALID = 0;
                M1_WDATA = 32'h8765_4321;
                M1_WSTRB = 4'b1111;
                M1_WVALID = 1;
                M1_WLAST = 1;
                wait (M1_WREADY);
                @(posedge ACLK);
                M1_WVALID = 0;
                M1_WLAST = 0;
                M1_BREADY = 1;
                wait (M1_BVALID);
                @(posedge ACLK);
                M1_BREADY = 0;
                $display("M1 BRESP: %b at %0t ns", M1_BRESP, $time);
                if (M1_BRESP == 2'b00) $display("Test 3 M1 Passed: M1 write to AXI-to-APB bridge successful at %0t ns", $time);
            end
        join

        #10;

        // Test 4: Concurrent writes to the same slave (M0 and M1 to memory)
        $display("Test 4: Concurrent writes to the same slave (memory) at %0t ns", $time);
        fork
            begin // M0 write to memory
                M0_AWADDR = 32'h0000_0020;
                M0_AWVALID = 1;
                wait (M0_AWREADY);
                @(posedge ACLK);
                M0_AWVALID = 0;
                M0_WDATA = 32'hAAAA_BBBB;
                M0_WSTRB = 4'b1111;
                M0_WVALID = 1;
                M0_WLAST = 1;
                wait (M0_WREADY);
                @(posedge ACLK);
                M0_WVALID = 0;
                M0_WLAST = 0;
                M0_BREADY = 1;
                wait (M0_BVALID);
                @(posedge ACLK);
                M0_BREADY = 0;
                $display("M0 BRESP: %b at %0t ns", M0_BRESP, $time);
                if (M0_BRESP == 2'b00) $display("Test 4 M0 Passed: M0 write to memory successful at %0t ns", $time);
            end
            begin // M1 write to memory
                M1_AWADDR = 32'h0000_0030;
                M1_AWVALID = 1;
                wait (M1_AWREADY);
                @(posedge ACLK);
                M1_AWVALID = 0;
                M1_WDATA = 32'hCCCC_DDDD;
                M1_WSTRB = 4'b1111;
                M1_WVALID = 1;
                M1_WLAST = 1;
                wait (M1_WREADY);
                @(posedge ACLK);
                M1_WVALID = 0;
                M1_WLAST = 0;
                M1_BREADY = 1;
                wait (M1_BVALID);
                @(posedge ACLK);
                M1_BREADY = 0;
                $display("M1 BRESP: %b at %0t ns", M1_BRESP, $time);
                if (M1_BRESP == 2'b00) $display("Test 4 M1 Passed: M1 write to memory successful at %0t ns", $time);
            end
        join

        #20;
        $display("Simulation completed at %0t ns", $time);
        $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("axi3_interconnect_tb.vcd");
        $dumpvars(0, axi3_interconnect_tb);
        // Explicitly add top-level signals to waveform
        $dumpvars(1, ACLK, ARESETn,
                  M0_AWADDR, M0_AWVALID, M0_AWREADY, M0_AWLEN, M0_AWSIZE, M0_AWBURST, M0_WDATA, M0_WSTRB, M0_WVALID, M0_WREADY, M0_WLAST, M0_BRESP, M0_BVALID, M0_BREADY,
                  M1_AWADDR, M1_AWVALID, M1_AWREADY, M1_AWLEN, M1_AWSIZE, M1_AWBURST, M1_WDATA, M1_WSTRB, M1_WVALID, M1_WREADY, M1_WLAST, M1_BRESP, M1_BVALID, M1_BREADY,
                  S0_AWADDR, S0_AWVALID, S0_AWREADY, S0_AWLEN, S0_AWSIZE, S0_AWBURST, S0_WDATA, S0_WSTRB, S0_WVALID, S0_WREADY, S0_WLAST, S0_BRESP, S0_BVALID, S0_BREADY,
                  S1_AWADDR, S1_AWVALID, S1_AWREADY, S1_AWLEN, S1_AWSIZE, S1_AWBURST, S1_WDATA, S1_WSTRB, S1_WVALID, S1_WREADY, S1_WLAST, S1_BRESP, S1_BVALID, S1_BREADY);
    end

endmodule