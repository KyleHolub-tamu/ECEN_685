//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_lv1_interface.sv
// Description: Basic CPU-LV1 interface with assertions
// Designers: Venky & Suru
//=====================================================================

`define CPU_RD_RESP_TIME    100
`define CPU_WR_RESP_TIME    100

interface cpu_lv1_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    reg   [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_reg = 32'hz ;

    wire  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1        ;
    logic [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1        ;
    logic                          cpu_rd                  ;
    logic                          cpu_wr                  ;
    logic                          cpu_wr_done             ;
    logic                          data_in_bus_cpu_lv1     ;

    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg ;

    // Assertions
    // property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty

    // cpu_wr_done should not be asserted without cpu_wr being asserted in previous cycle
    assert_cpu_wr_done: assert property (prop_sig1_before_sig2(cpu_wr,cpu_wr_done))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_done Failed: cpu_wr_done asserted without cpu_wr_done"))

    // cpu_wr and cpu_rd should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_rd;
        @(posedge clk)
          not(cpu_rd && cpu_wr);
    endproperty

    assert_simult_cpu_wr_rd: assert property (prop_simult_cpu_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_simult_cpu_wr_rd Failed: cpu_wr and cpu_rd asserted simultaneously"))

    // data_in_bus_cpu_lv1 should not be asserted without cpu_rd being asserted in previous cycle
    assert_data_in_bus_cpu_rd: assert property (prop_sig1_before_sig2(cpu_rd,data_in_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_in_bus_cpu_rd Failed: data_in_bus_cpu_lv1 asserted without cpu_rd"))

    // property that checks that signal_2 needs to be legal(should not have x's or z's) when signal_1 is asserted
    property prop_legal(signal_1,signal_2);
    @(posedge clk)
        signal_1  |-> not($isunknown(signal_2));
    endproperty

    assert_data_bus_legal: assert property (prop_legal({cpu_wr | data_in_bus_cpu_lv1},data_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_bus_legal Failed: data_bus_cpu_lv1 not legal when either cpu_wr or data_in_bus_cpu_lv1 are high"))

    assert_addr_bus_legal: assert property (prop_legal({cpu_rd | cpu_wr},addr_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_addr_bus_legal Failed: addr_bus_cpu_lv1 is not legal value when either cpu_rd or cpu_wr is high"))

    // property that checks that signal_2 needs to be stable when signal_1 is asserted
    property prop_stable(signal_1,signal_2);
    @(posedge clk)
        $rose(signal_1)  |=> $stable(signal_2) until $fell(signal_1);
    endproperty

    assert_data_bus_stable: assert property (prop_stable({cpu_wr | data_in_bus_cpu_lv1},data_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_bus_stable Failed: data_bus_cpu_lv1 not legal when either cpu_wr or data_in_bus_cpu_lv1 are high"))

    assert_addr_bus_stable: assert property (prop_stable({cpu_rd | cpu_wr},addr_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_addr_bus_stable Failed: addr_bus_cpu_lv1 is not legal value when either cpu_rd or cpu_wr is high"))

    // property that checks that signal_2 needs to be asserted within TIMEOUT_VAL cycles of signal_1 assertion
    property prop_sig2_within_sig1_rose(signal_1,signal_2,int TIMEOUT_VAL);
    @(posedge clk)
        $rose(signal_1) |-> ## [1:TIMEOUT_VAL] $rose(signal_2) ##1 $fell(signal_1) ##1 $fell(signal_2);
    endproperty

    // timeout checks for cpu_rd and cpu_wr requests (not valid for I-cache writes)
    assert_cpu_rd_resp_time: assert property (prop_sig2_within_sig1_rose(cpu_rd,data_in_bus_cpu_lv1,`CPU_RD_RESP_TIME))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_rd_resp_time Failed: data_in_bus_cpu_lv1 not asserted within %0d cycles after cpu_rd goes high",`CPU_RD_RESP_TIME))

    property prop_cpu_wr_resp_time;
    @(posedge clk) disable iff (addr_bus_cpu_lv1 <= `IL_DL_ADDR_BOUND) // not an error for I-cache write
        $rose(cpu_wr) |-> ## [1:`CPU_WR_RESP_TIME] $rose(cpu_wr_done) ##1 $fell(cpu_wr) ##1 $fell(cpu_wr_done);
    endproperty

    assert_cpu_wr_resp_time: assert property (prop_cpu_wr_resp_time)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_resp_time Failed: cpu_wr_done not asserted within %0d cycles after cpu_wr goes high",`CPU_WR_RESP_TIME))

endinterface
