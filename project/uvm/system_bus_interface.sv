//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_interface.sv
// Description: Basic system bus interface including arbiter
// Designers: Venky & Suru
//=====================================================================

`define LV2_WR_RESP_TIME        10
`define BUS_RD_RDX_RESP_TIME    10
`define INVALID_RESP_TIME       1

interface system_bus_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1        = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1        = `ADDR_WID_LV1       ;
`ifdef DUAL_CORE1 // check this def
    parameter NUM_CORE            = 2;
`else
    parameter NUM_CORE            = 4;
`endif // DUAL_CORE


    wire [DATA_WID_LV1 - 1 : 0] data_bus_lv1_lv2     ;
    wire [ADDR_WID_LV1 - 1 : 0] addr_bus_lv1_lv2     ;
    wire                        bus_rd               ;
    wire                        bus_rdx              ;
    wire                        lv2_rd               ;
    wire                        lv2_wr               ;
    wire                        lv2_wr_done          ;
    wire                        cp_in_cache          ;
    wire                        data_in_bus_lv1_lv2  ;

    wire                        shared               ;
    wire                        all_invalidation_done;
    wire                        invalidate           ;

    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_gnt_proc ;
    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_req_proc ;
    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_gnt_snoop;
    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_req_snoop;
    logic                       bus_lv1_lv2_gnt_lv2  ;
    logic                       bus_lv1_lv2_req_lv2  ;

    // Assertions
    // property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty

    // lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))

    // data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
    assert_read_response: assert property (prop_sig1_before_sig2(lv2_rd,{data_in_bus_lv1_lv2|cp_in_cache}))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_read_response Failed: lv2_rd not asserted before either data_in_bus_lv1_lv2 or cp_in_cache goes high "))

    // Proc side: gnt should not be asserted without corresponding req
    generate
        for (genvar i = 0; i < NUM_CORE; i++)
        begin : assert_proc_req_before_gnt
            assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_proc[i],bus_lv1_lv2_gnt_proc[i]))
            else
            `uvm_error("system_bus_interface",$sformatf("Assertion assert_proc_req_before_gnt Failed: proc_req not asserted before proc_gnt goes high"))
        end
    endgenerate

    // Snoop side: gnt should not be asserted without corresponding req
    generate
        for (genvar i = 0; i < NUM_CORE; i++)
        begin : assert_snoop_req_before_gnt
            assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_snoop[i],bus_lv1_lv2_gnt_snoop[i]))
            else
            `uvm_error("system_bus_interface",$sformatf("Assertion assert_snoop_req_before_gnt Failed: snoop_req not asserted before snoop_gnt goes high"))
        end
    endgenerate

    // Lv2: gnt should not be asserted without corresponding req for proc side
    assert_lv2_req_before_gnt: assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_lv2,bus_lv1_lv2_gnt_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_req_before_gnt Failed: lv2_req not asserted before lv2_gnt goes high"))

    // Either one among bus_rd, bus_rdx or invalidate is asserted or none
    property prop_bus_rd_rdx_invalidate;
        @(posedge clk)
          $onehot0({bus_rd,bus_rdx,invalidate});
    endproperty

    assert_bus_rd_rdx_invalidate_exclusive: assert property (prop_bus_rd_rdx_invalidate)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_rd_rdx_invalidate_exclusive Failed: 2 or more among bus_rd, bus_rdx, invalidate asserted at the same time"))

    // cp_in_cache, lv2_wr should not be asserted when invalidate is asserted
    property prop_invalidate_high;
        @(posedge clk)
          invalidate |-> not(cp_in_cache or lv2_wr);
    endproperty

    assert_invalidate_high: assert property (prop_invalidate_high)
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidate_high Failed: cp_in_cache or lv2_wr are not expected to be high when invalidate is asserted"))

    // check that at a time a maximum of 1 grant each on snoop or bus side is provided
    property prop_gnt_assertion;
        @(posedge clk)
          ($onehot0(bus_lv1_lv2_gnt_proc) and $onehot0(bus_lv1_lv2_gnt_snoop));
    endproperty

    assert_gnt_assertion: assert property (prop_gnt_assertion)
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_gnt_assertion Failed: Multiple grants on proc/snoop side"))

    // cp_in_cache need to be asserted for simultaneous lv2_rd and lv2_wr
    property prop_simult_lv2_rd_wr_with_cp_in_cache;
        @(posedge clk)
          (lv2_rd & lv2_wr) |-> cp_in_cache;
    endproperty

    assert_simult_lv2_rd_wr_with_cp_in_cache: assert property (prop_simult_lv2_rd_wr_with_cp_in_cache)
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_simult_lv2_rd_wr_with_cp_in_cache Failed: Simulataneous lv2_rd and lv2_wr without cp_in_cache asserted"))

    // property that checks that signal_2 needs to be asserted within TIMEOUT_VAL cycles of signal_1 assertion, subsequently signal_1 one fall and then signal_2 falls
    property prop_req_done_pair_sequence(signal_1,signal_2,int TIMEOUT_VAL);
    @(posedge clk)
        $rose(signal_1) |-> ## [1:TIMEOUT_VAL] $rose(signal_2) ##1 ($fell(signal_1) or $isunknown(signal_1)) ##1 ($fell(signal_2) or $isunknown(signal_2));
    endproperty

    // timeout checks for the responses to: lv2_wr, bus_rd/bus_rdx, invalidate
    assert_lv2_wr_resp_time: assert property (prop_req_done_pair_sequence(lv2_wr,lv2_wr_done,`LV2_WR_RESP_TIME))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_resp Failed: lv2_wr_done not asserted within %0d cycles after lv2_wr goes high or sequence not valid",`LV2_WR_RESP_TIME))

    assert_bus_rd_rdx_resp_time: assert property (prop_req_done_pair_sequence({lv2_rd | bus_rd | bus_rdx},data_in_bus_lv1_lv2,`BUS_RD_RDX_RESP_TIME))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_rd_rdx_resp Failed: data_in_bus_lv1_lv2 not asserted within %0d cycles after either bus_rd or bus_rdx goes high or sequence not valid",`BUS_RD_RDX_RESP_TIME))

    // property that checks that signal_2 needs to be asserted within TIMEOUT_VAL cycles of signal_1 assertion, subsequently signal_1 one fall and signal_2 falls
    property prop_invalidate_pair_sequence(signal_1,signal_2,int TIMEOUT_VAL);
    @(posedge clk)
        $rose(signal_1) |-> ## [1:TIMEOUT_VAL] $rose(signal_2) ##1 (($fell(signal_1)or $isunknown(signal_1)) and $fell(signal_2));
    endproperty

    assert_invalidate_resp_time: assert property (prop_invalidate_pair_sequence(invalidate,all_invalidation_done,`INVALID_RESP_TIME))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidate_resp_time Failed: all_invalidation_done not asserted within %0d cycles after invalidate goes high or sequence not valid",`INVALID_RESP_TIME))

    // property that checks that signal_2 needs to be legal(should not have x's or z's) when signal_1 is asserted
    property prop_legal(signal_1,signal_2);
    @(posedge clk)
        signal_1  |-> not($isunknown(signal_2));
    endproperty

    // address bus legality check
    // When either bus_rd, bus_rdx, invalidate, lv2_rd, lv2_wr is asserted, addr_bus_lv1_lv2 should not have x's or z's
    assert_addr_bus_lv2_legal: assert property (prop_legal({bus_rd | bus_rdx | invalidate | lv2_rd | lv2_wr},addr_bus_lv1_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_addr_bus_lv2_legal Failed: address bus is expected to be legal when either bus_rd, bus_rdx, invalidate, lv2_rd or lv2_wr is high"))

    // data_bus_lv1_lv2 to have no X or Z when (data_in_bus_lv1_lv2) or lv2_wr is asserted
    assert_data_bus_lv2_legal: assert property (prop_legal({data_in_bus_lv1_lv2 | lv2_wr},data_bus_lv1_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_data_bus_lv2_legal Failed: data bus is expected to be legal when either lv2_wr or data_in_bus_lv1_lv2 are high"))

    // shared is legal when data_in_bus_lv1_lv2 is high
    assert_shared_legal_when_data_in_bus: assert property (prop_legal(data_in_bus_lv1_lv2,shared))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_shared_legal_when_data_in_bus Failed: data_in_bus_lv1_lv2 high, but shared is not legal"))


    // property that checks that signal_2 needs to be stable when signal_1 is asserted
    property prop_stable(signal_1,signal_2);
    @(posedge clk)
        $rose(signal_1)  |=> $stable(signal_2) until ($fell(signal_1) or $isunknown(signal_1));
    endproperty

    // address bus stablility check
    // When either bus_rd, bus_rdx, invalidate, lv2_rd, lv2_wr is asserted, addr_bus_lv1_lv2 should be stable
    assert_addr_bus_lv2_stable: assert property (prop_stable({bus_rd | bus_rdx | invalidate | lv2_rd | lv2_wr},addr_bus_lv1_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_addr_bus_lv2_stable Failed: address bus is expected to be stable when either bus_rd, bus_rdx, invalidate, lv2_rd or lv2_wr is high"))

    // data_bus_lv1_lv2 to be stable when (data_in_bus_lv1_lv2) or lv2_wr is asserted
    assert_data_bus_lv2_stable: assert property (prop_stable({data_in_bus_lv1_lv2 | lv2_wr},data_bus_lv1_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_data_bus_lv2_stable Failed: data bus is expected to be stable when either lv2_wr or data_in_bus_lv1_lv2 are high"))

    // property for implication: signal_1 is to be high when signal 2 is high after TIME_AFTER cycles if 'enable' is high
    property prop_sig1_when_sig2_and_en(signal_1,signal_2, enable);
    @(posedge clk)
        (signal_2  && enable) |-> signal_1;
    endproperty

    // Either bus_rd or bus_rdx is high when lv2_rd is high, enable check only for
    // Dcache
    assert_bus_rd_rdx_when_lv2_rd: assert property (prop_sig1_when_sig2_and_en({bus_rd | bus_rdx},lv2_rd, (| addr_bus_lv1_lv2[31:30])))
        else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_rd_rdx_when_lv2_rd Failed: lv2_rd high, but neither bus_rd or bus_rdx are high"))

    // lv2_rd is high when either bus_rd or bus_rdx is high, enable check only for
    // Dcache
    assert_lv2_rd_when_bus_rd_rdx: assert property (prop_sig1_when_sig2_and_en(lv2_rd,{bus_rd | bus_rdx}, (| addr_bus_lv1_lv2[31:30])))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_rd_when_bus_rd_rdx Failed: Either bus_rd or bus_rdx is high, but lv2_rd is not high"))

    // At least one of the proc gnt has to be high in the previous cycle when any snoop/l2 req is high
    assert_proc_gnt_when_snoop_l2_req: assert property (prop_sig1_when_sig2_and_en({| $past(bus_lv1_lv2_gnt_proc)},{| {bus_lv1_lv2_req_snoop,bus_lv1_lv2_req_lv2}}, 1))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion asseert_proc_gnt_when_snoop_l2_req Failed: One of the snoop or lv2 bus req is high, but none of the proc gnt is high"))

    property prop_proc_gnt_when_bus_side_sig;
    @(posedge clk)
        (bus_rd | bus_rdx | invalidate | lv2_rd | lv2_wr | shared | all_invalidation_done | cp_in_cache | lv2_wr_done | data_in_bus_lv1_lv2) |-> $past($onehot(bus_lv1_lv2_gnt_proc));
    endproperty

    // check that none of the processor side bus signals are not driven without grant being asserted
    assert_proc_gnt_when_bus_side_sig: assert property (prop_proc_gnt_when_bus_side_sig)
        else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_proc_gnt_when_bus_side_sig Failed: Either bus_rd, bus_rdx, invalidate, lv2_rd or lv2_wr is high without one of the bus_lv1_lv2_gnt_proc being high"))


    // property to check that signal_1 is legal one cycle after signal_2 goes high , and enable is high
    property prop_sig1_leg_when_sig2_en(signal_1,signal_2, enable);
    @(posedge clk)
        $rose(signal_2) |=> (!enable or !($isunknown(signal_1))) until $fell(signal_2);
    endproperty

    // DCACHE bus_rd, bus_rdx, lv2_rd, lv2_wr, invalidate should be legal next cycle after proc_gnt getting asserted
    assert_bus_sig_legal_after_proc_gnt: assert property (prop_sig1_leg_when_sig2_en({bus_rd,bus_rdx,invalidate,lv2_rd,lv2_wr},{| bus_lv1_lv2_gnt_proc}, (| addr_bus_lv1_lv2[31:30 ])))
        else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_sig_legal_after_proc_gnt Failed: One of the bus_lv1_lv2_gnt_proc high, but either of bus_rd,bus_rdx,invalidate,lv2_rd,lv2_wr are not legal after 1 cycle"))

    // ICACHE bus_rd, bus_rdx, lv2_rd, lv2_wr, invalidate should be legal next cycle after proc_gnt getting asserted
    assert_bus_sig_legal_after_proc_gnt_icache: assert property (prop_sig1_leg_when_sig2_en({lv2_rd,lv2_wr},{| bus_lv1_lv2_gnt_proc}, 1))
        else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_sig_legal_after_proc_gnt Failed: One of the bus_lv1_lv2_gnt_proc high, but either lv2_rd or lv2_wr is not legal after 1 cycle"))

    // cp_in_cache should be legal next cycle after either bus_rd or bus_rdx getting asserted
    assert_cp_in_cache_legal_after_bus_rd_rdx: assert property (prop_sig1_leg_when_sig2_en(cp_in_cache,{bus_rd | bus_rdx},1))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_cp_in_cache_legal_after_bus_rd_rdx Failed: Either bus_rd or bus_rdx high, but cp_in_cache is not legal after 1 cycle"))

    // all_invalidation_done should be legal next cycle after invalidate getting asserted
    assert_all_invalid_done_legal_after_invalidate: assert property (prop_sig1_leg_when_sig2_en(all_invalidation_done,invalidate,1))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_all_invalid_done_legal_after_invalidate Failed: invalidate high, but all_invalidation_done is not legal after 1 cycle"))

    // proc req should always be legal
    assert_proc_req_legal: assert property(@(posedge clk) ##1 !($isunknown(bus_lv1_lv2_req_proc)));

    // to check that when data_in_bus_lv1_lv2 rises and if proc_gnt was high in the previous cycle, proc_req should go low along with bus_rd or bus_rdx in the next cycle
    property prop_proc_resp_to_data_in_bus(proc_gnt,proc_req);
    @(posedge clk)
        ($rose(data_in_bus_lv1_lv2) & $past(proc_gnt)) |=> ($fell(proc_req));
    endproperty

    // response to data_in_bus_lv1_lv2 going high
    generate
        for (genvar i = 0; i < NUM_CORE; i++)
        begin : assert_proc_resp_to_data_in_bus
            assert property (prop_proc_resp_to_data_in_bus(bus_lv1_lv2_gnt_proc[i],bus_lv1_lv2_req_proc[i]))
            else
            `uvm_error("system_bus_interface",$sformatf("Assertion assert_proc_resp_to_data_in_bus Failed: data_in_bus_lv1_lv2 goes high, but CPU%0d which had bus grant does not remove bus request or bus_rd or bus_rdx is not made low",i))
        end
    endgenerate

    // to check that when all_invalidation_done rises and if proc_gnt was high in the previous cycle, proc_req should go low along with invalidate in the next cycle
    property prop_proc_resp_to_all_invalidation_done(proc_gnt,proc_req);
    @(posedge clk)
        ($rose(all_invalidation_done) & $past(proc_gnt)) |=> ($fell(proc_req));
    endproperty

    // response to all_invalidation_done going high
    generate
        for (genvar i = 0; i < NUM_CORE; i++)
        begin : assert_proc_resp_to_all_invalidation_done
            assert property (prop_proc_resp_to_all_invalidation_done(bus_lv1_lv2_gnt_proc[i],bus_lv1_lv2_req_proc[i]))
            else
            `uvm_error("system_bus_interface",$sformatf("Assertion assert_proc_resp_to_all_invalidation_done Failed: all_invalidation_done goes high, but CPU%0d which had bus grant does not remove bus request or invalidate is not made low",i))
        end
    endgenerate

endinterface
