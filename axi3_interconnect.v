module axi3_interconnect (
    // Global signals
    input wire ACLK,
    input wire ARESETn,

    // AXI3 Master 0 (RISC-V Processor)
    input wire [31:0] M0_AWADDR,
    input wire M0_AWVALID,
    output wire M0_AWREADY,
    input wire [3:0] M0_AWLEN,  // AXI3: 4 bits (1 to 16 beats)
    input wire [2:0] M0_AWSIZE,
    input wire [1:0] M0_AWBURST,
    input wire [31:0] M0_WDATA,
    input wire [3:0] M0_WSTRB,
    input wire M0_WVALID,
    output wire M0_WREADY,
    input wire M0_WLAST,
    output wire [1:0] M0_BRESP,
    output wire M0_BVALID,
    input wire M0_BREADY,

    // AXI3 Master 1 (DMA)
    input wire [31:0] M1_AWADDR,
    input wire M1_AWVALID,
    output wire M1_AWREADY,
    input wire [3:0] M1_AWLEN,  // AXI3: 4 bits
    input wire [2:0] M1_AWSIZE,
    input wire [1:0] M1_AWBURST,
    input wire [31:0] M1_WDATA,
    input wire [3:0] M1_WSTRB,
    input wire M1_WVALID,
    output wire M1_WREADY,
    input wire M1_WLAST,
    output wire [1:0] M1_BRESP,
    output wire M1_BVALID,
    input wire M1_BREADY,

    // AXI3 Slave 0 (Memory)
    output wire [31:0] S0_AWADDR,
    output wire S0_AWVALID,
    input wire S0_AWREADY,
    output wire [3:0] S0_AWLEN,  // AXI3: 4 bits
    output wire [2:0] S0_AWSIZE,
    output wire [1:0] S0_AWBURST,
    output wire [31:0] S0_WDATA,
    output wire [3:0] S0_WSTRB,
    output wire S0_WVALID,
    input wire S0_WREADY,
    output wire S0_WLAST,
    input wire [1:0] S0_BRESP,
    input wire S0_BVALID,
    output wire S0_BREADY,

    // AXI3 Slave 1 (AXI-to-APB Bridge)
    output wire [31:0] S1_AWADDR,
    output wire S1_AWVALID,
    input wire S1_AWREADY,
    output wire [3:0] S1_AWLEN,  // AXI3: 4 bits
    output wire [2:0] S1_AWSIZE,
    output wire [1:0] S1_AWBURST,
    output wire [31:0] S1_WDATA,
    output wire [3:0] S1_WSTRB,
    output wire S1_WVALID,
    input wire S1_WREADY,
    output wire S1_WLAST,
    input wire [1:0] S1_BRESP,
    input wire S1_BVALID,
    output wire S1_BREADY
);

    // Arbitration state
    reg [1:0] arb_state; // 0: Idle, 1: Master 0 active, 2: Master 1 active
    reg [1:0] last_granted; // Last master granted access (for round-robin)

    // Address decoding
    wire s0_select_m0 = (M0_AWADDR[31:28] == 4'h0); // Memory: 0x0000_0000 to 0x0FFF_FFFF
    wire s1_select_m0 = (M0_AWADDR[31:28] == 4'h1); // AXI-to-APB: 0x1000_0000 to 0x1FFF_FFFF
    wire s0_select_m1 = (M1_AWADDR[31:28] == 4'h0);
    wire s1_select_m1 = (M1_AWADDR[31:28] == 4'h1);

    // Arbitration logic
    wire m0_request = M0_AWVALID && (s0_select_m0 || s1_select_m0);
    wire m1_request = M1_AWVALID && (s0_select_m1 || s1_select_m1);
    wire grant_m0 = m0_request && (!m1_request || (last_granted == 1 && !m0_request));
    wire grant_m1 = m1_request && !grant_m0;

    // Internal signals for selected master
    reg [31:0] selected_awaddr;
    reg selected_awvalid;
    reg [3:0] selected_awlen;  // AXI3: 4 bits
    reg [2:0] selected_awsize;
    reg [1:0] selected_awburst;
    reg [31:0] selected_wdata;
    reg [3:0] selected_wstrb;
    reg selected_wvalid;
    reg selected_wlast;
    wire selected_awready;
    wire selected_wready;
    wire [1:0] selected_bresp;
    wire selected_bvalid;
    reg selected_bready;

    // Slave selection
    wire s0_selected = (arb_state == 1 && s0_select_m0) || (arb_state == 2 && s0_select_m1);
    wire s1_selected = (arb_state == 1 && s1_select_m0) || (arb_state == 2 && s1_select_m1);

    // Arbitration state machine
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            arb_state <= 2'd0;
            last_granted <= 2'd0;
        end else begin
            case (arb_state)
                2'd0: begin // Idle
                    if (grant_m0) begin
                        arb_state <= 2'd1;
                        last_granted <= 2'd0;
                    end else if (grant_m1) begin
                        arb_state <= 2'd2;
                        last_granted <= 2'd1;
                    end
                end
                2'd1: begin // Master 0 active
                    if (M0_BVALID && M0_BREADY) begin
                        arb_state <= 2'd0; // Transaction complete
                    end
                end
                2'd2: begin // Master 1 active
                    if (M1_BVALID && M1_BREADY) begin
                        arb_state <= 2'd0;
                    end
                end
            endcase
        end
    end

    // Master selection
    always @(*) begin
        if (arb_state == 2'd1) begin
            selected_awaddr = M0_AWADDR;
            selected_awvalid = M0_AWVALID;
            selected_awlen = M0_AWLEN;
            selected_awsize = M0_AWSIZE;
            selected_awburst = M0_AWBURST;
            selected_wdata = M0_WDATA;
            selected_wstrb = M0_WSTRB;
            selected_wvalid = M0_WVALID;
            selected_wlast = M0_WLAST;
            selected_bready = M0_BREADY;
        end else if (arb_state == 2'd2) begin
            selected_awaddr = M1_AWADDR;
            selected_awvalid = M1_AWVALID;
            selected_awlen = M1_AWLEN;
            selected_awsize = M1_AWSIZE;
            selected_awburst = M1_AWBURST;
            selected_wdata = M1_WDATA;
            selected_wstrb = M1_WSTRB;
            selected_wvalid = M1_WVALID;
            selected_wlast = M1_WLAST;
            selected_bready = M1_BREADY;
        end else begin
            selected_awaddr = 32'd0;
            selected_awvalid = 1'b0;
            selected_awlen = 4'd0;
            selected_awsize = 3'd0;
            selected_awburst = 2'd0;
            selected_wdata = 32'd0;
            selected_wstrb = 4'd0;
            selected_wvalid = 1'b0;
            selected_wlast = 1'b0;
            selected_bready = 1'b0;
        end
    end

    // Route to slaves
    assign S0_AWADDR = s0_selected ? selected_awaddr : 32'd0;
    assign S0_AWVALID = s0_selected ? selected_awvalid : 1'b0;
    assign S0_AWLEN = s0_selected ? selected_awlen : 4'd0;
    assign S0_AWSIZE = s0_selected ? selected_awsize : 3'd0;
    assign S0_AWBURST = s0_selected ? selected_awburst : 2'd0;
    assign S0_WDATA = s0_selected ? selected_wdata : 32'd0;
    assign S0_WSTRB = s0_selected ? selected_wstrb : 4'd0;
    assign S0_WVALID = s0_selected ? selected_wvalid : 1'b0;
    assign S0_WLAST = s0_selected ? selected_wlast : 1'b0;
    assign S0_BREADY = s0_selected ? selected_bready : 1'b0;

    assign S1_AWADDR = s1_selected ? selected_awaddr : 32'd0;
    assign S1_AWVALID = s1_selected ? selected_awvalid : 1'b0;
    assign S1_AWLEN = s1_selected ? selected_awlen : 4'd0;
    assign S1_AWSIZE = s1_selected ? selected_awsize : 3'd0;
    assign S1_AWBURST = s1_selected ? selected_awburst : 2'd0;
    assign S1_WDATA = s1_selected ? selected_wdata : 32'd0;
    assign S1_WSTRB = s1_selected ? selected_wstrb : 4'd0;
    assign S1_WVALID = s1_selected ? selected_wvalid : 1'b0;
    assign S1_WLAST = s1_selected ? selected_wlast : 1'b0;
    assign S1_BREADY = s1_selected ? selected_bready : 1'b0;

    // Route responses back to masters
    assign selected_awready = s0_selected ? S0_AWREADY : (s1_selected ? S1_AWREADY : 1'b0);
    assign selected_wready = s0_selected ? S0_WREADY : (s1_selected ? S1_WREADY : 1'b0);
    assign selected_bresp = s0_selected ? S0_BRESP : (s1_selected ? S1_BRESP : 2'd0);
    assign selected_bvalid = s0_selected ? S0_BVALID : (s1_selected ? S1_BVALID : 1'b0);

    assign M0_AWREADY = (arb_state == 2'd1) ? selected_awready : 1'b0;
    assign M0_WREADY = (arb_state == 2'd1) ? selected_wready : 1'b0;
    assign M0_BRESP = (arb_state == 2'd1) ? selected_bresp : 2'd0;
    assign M0_BVALID = (arb_state == 2'd1) ? selected_bvalid : 1'b0;

    assign M1_AWREADY = (arb_state == 2'd2) ? selected_awready : 1'b0;
    assign M1_WREADY = (arb_state == 2'd2) ? selected_wready : 1'b0;
    assign M1_BRESP = (arb_state == 2'd2) ? selected_bresp : 2'd0;
    assign M1_BVALID = (arb_state == 2'd2) ? selected_bvalid : 1'b0;
endmodule