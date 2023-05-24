//=====================================================================
// Project: 4 core MESI cache design
// File Name: top.sv
// Description: testbench for cache top with environment
// Designers: Venky & Suru
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/12/01  1.0     Initial Release
// 2016/12/02  2.0     Added CPU MESI and LRU interface
//=====================================================================

`ifdef DUAL_CORE
    `define INST_TOP_CORE inst_cache_lv1_dualcore
    `define NUM_CORE 2
`else // DUAL_CORE
    `define INST_TOP_CORE inst_cache_lv1_multicore
    `define NUM_CORE 4
`endif // DUAL_CORE

`define CORE_0 0
`define CORE_1 1
`define CORE_2 2
`define CORE_3 3

`define CURRENT_MESI_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.current_mesi_proc
`define CURRENT_MESI_SNOOP(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.current_mesi_snoop
`define UPDATED_MESI_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.updated_mesi_proc
`define UPDATED_MESI_SNOOP(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.updated_mesi_snoop
`define MESI_CPU_RD(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.cpu_rd
`define MESI_CPU_WR(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.cpu_wr
`define MESI_BUS_RD(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.bus_rd
`define MESI_BUS_RDX(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.bus_rdx
`define MESI_INVALIDATE(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_block_lv1_dl.invalidate
`define CACHE_LRU_REPL_DL_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_controller_lv1_dl.inst_lru_block_lv1.lru_replacement_proc
`define CACHE_LRU_REPL_IL_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_il.inst_cache_controller_lv1_il.inst_lru_block_lv1.lru_replacement_proc
`define CACHE_LRU_ACCD_DL_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_controller_lv1_dl.inst_lru_block_lv1.blk_accessed_main
`define CACHE_LRU_ACCD_IL_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_il.inst_cache_controller_lv1_il.inst_lru_block_lv1.blk_accessed_main
`define CACHE_LRU_UPDATE_DL_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_dl.inst_cache_controller_lv1_dl.inst_lru_block_lv1.lru_update
`define CACHE_LRU_UPDATE_IL_PROC(CPU_NO) inst_cache_top.`INST_TOP_CORE.inst_cache_lv1_unicore_``CPU_NO``.inst_cache_wrapper_lv1_il.inst_cache_controller_lv1_il.inst_lru_block_lv1.lru_update

`define CPU_LRU_IF_ASSIGN assign inst_cpu_mesi_lru_if

// define macros for CPU MESI and LRU interface code
`define CPU_LRU_MESI_IF(CPU_NO) \
`CPU_LRU_IF_ASSIGN[``CPU_NO``].current_mesi_proc = `CURRENT_MESI_PROC(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].current_mesi_snoop = `CURRENT_MESI_SNOOP(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].updated_mesi_proc = `UPDATED_MESI_PROC(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].updated_mesi_snoop = `UPDATED_MESI_SNOOP(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].cpu_rd = `MESI_CPU_RD(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].cpu_wr = `MESI_CPU_WR(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].bus_rd = `MESI_BUS_RD(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].bus_rdx = `MESI_BUS_RDX(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].invalidate = `MESI_INVALIDATE(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].lru_replacement_proc_dl = `CACHE_LRU_REPL_DL_PROC(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].lru_replacement_proc_il = `CACHE_LRU_REPL_IL_PROC(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].blk_accessed_main_dl = `CACHE_LRU_ACCD_DL_PROC(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].blk_accessed_main_il = `CACHE_LRU_ACCD_IL_PROC(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].lru_update_dl = `CACHE_LRU_UPDATE_DL_PROC(``CPU_NO``);\
`CPU_LRU_IF_ASSIGN[``CPU_NO``].lru_update_il = `CACHE_LRU_UPDATE_IL_PROC(``CPU_NO``);\

module top;

    // import the UVM library
    import uvm_pkg::*;
    // include the UVM macros
    `include "uvm_macros.svh"

    // import the CPU package
    import cpu_pkg::*;

    //include the environment
    `include "env.sv"
    //include the test library
    `include "test_lib.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;
    parameter DATA_WID_LV2           = `DATA_WID_LV2       ;
    parameter ADDR_WID_LV2           = `ADDR_WID_LV2       ;

    reg                           clk;
    wire [DATA_WID_LV2 - 1   : 0] data_bus_lv2_mem;
    wire [ADDR_WID_LV2 - 1   : 0] addr_bus_lv2_mem;
    wire                          data_in_bus_lv2_mem;
    wire                          mem_rd;
    wire                          mem_wr;
    wire                          mem_wr_done;

    wire [3:0]                    cpu_lv1_if_cpu_rd;
    wire [3:0]                    cpu_lv1_if_cpu_wr;
    wire [3:0]                    cpu_lv1_if_cpu_wr_done;
    wire [3:0]                    cpu_lv1_if_data_in_bus_cpu_lv1;

    // Instantiate the interfaces
    cpu_lv1_interface       inst_cpu_lv1_if[0:3](clk);
    system_bus_interface    inst_system_bus_if(clk);
    cpu_mesi_lru_interface  inst_cpu_mesi_lru_if[0:3](clk);

    // Assign internal signals of the interface
    assign inst_system_bus_if.data_bus_lv1_lv2      = inst_cache_top.data_bus_lv1_lv2;
    assign inst_system_bus_if.addr_bus_lv1_lv2      = inst_cache_top.addr_bus_lv1_lv2;
    assign inst_system_bus_if.data_in_bus_lv1_lv2   = inst_cache_top.data_in_bus_lv1_lv2;
    assign inst_system_bus_if.lv2_rd                = inst_cache_top.lv2_rd;
    assign inst_system_bus_if.lv2_wr                = inst_cache_top.lv2_wr;
    assign inst_system_bus_if.lv2_wr_done           = inst_cache_top.lv2_wr_done;
    assign inst_system_bus_if.cp_in_cache           = inst_cache_top.cp_in_cache;
    assign inst_system_bus_if.shared                = inst_cache_top.`INST_TOP_CORE.shared;
    assign inst_system_bus_if.all_invalidation_done = inst_cache_top.`INST_TOP_CORE.all_invalidation_done;
    assign inst_system_bus_if.invalidate            = inst_cache_top.`INST_TOP_CORE.invalidate;
    assign inst_system_bus_if.bus_rd                = inst_cache_top.`INST_TOP_CORE.bus_rd;
    assign inst_system_bus_if.bus_rdx               = inst_cache_top.`INST_TOP_CORE.bus_rdx;

    // Cache MESI state and LRU interface
    `CPU_LRU_MESI_IF(`CORE_0)
    `CPU_LRU_MESI_IF(`CORE_1)
`ifndef DUAL_CORE
    // Cache MESI state and LRU interface for cores 3 and 4
    `CPU_LRU_MESI_IF(`CORE_2)
    `CPU_LRU_MESI_IF(`CORE_3)
`endif // DUAL_CORE

    // instantiate memory golden model
    memory #(
            .DATA_WID(DATA_WID_LV2),
            .ADDR_WID(ADDR_WID_LV2)
            )
             inst_memory (
                            .clk                (clk                ),
                            .data_bus_lv2_mem   (data_bus_lv2_mem   ),
                            .addr_bus_lv2_mem   (addr_bus_lv2_mem   ),
                            .mem_rd             (mem_rd             ),
                            .mem_wr             (mem_wr             ),
                            .mem_wr_done        (mem_wr_done        ),
                            .data_in_bus_lv2_mem(data_in_bus_lv2_mem)
                         );

    // instantiate arbiter golden model
    lrs_arbiter  inst_arbiter (
                                    .clk(clk),
                                    .bus_lv1_lv2_gnt_proc (inst_system_bus_if.bus_lv1_lv2_gnt_proc ),
                                    .bus_lv1_lv2_req_proc (inst_system_bus_if.bus_lv1_lv2_req_proc ),
                                    .bus_lv1_lv2_gnt_snoop(inst_system_bus_if.bus_lv1_lv2_gnt_snoop),
                                    .bus_lv1_lv2_req_snoop(inst_system_bus_if.bus_lv1_lv2_req_snoop),
                                    .bus_lv1_lv2_gnt_lv2  (inst_system_bus_if.bus_lv1_lv2_gnt_lv2  ),
                                    .bus_lv1_lv2_req_lv2  (inst_system_bus_if.bus_lv1_lv2_req_lv2  )
                               );

    assign cpu_lv1_if_cpu_rd                = {inst_cpu_lv1_if[3].cpu_rd,inst_cpu_lv1_if[2].cpu_rd,
                                               inst_cpu_lv1_if[1].cpu_rd,inst_cpu_lv1_if[0].cpu_rd};
    assign cpu_lv1_if_cpu_wr                = {inst_cpu_lv1_if[3].cpu_wr,inst_cpu_lv1_if[2].cpu_wr,
                                               inst_cpu_lv1_if[1].cpu_wr,inst_cpu_lv1_if[0].cpu_wr};

    assign {inst_cpu_lv1_if[3].cpu_wr_done,inst_cpu_lv1_if[2].cpu_wr_done,inst_cpu_lv1_if[1].cpu_wr_done,inst_cpu_lv1_if[0].cpu_wr_done} = cpu_lv1_if_cpu_wr_done;

    assign {inst_cpu_lv1_if[3].data_in_bus_cpu_lv1,inst_cpu_lv1_if[2].data_in_bus_cpu_lv1,inst_cpu_lv1_if[1].data_in_bus_cpu_lv1,inst_cpu_lv1_if[0].data_in_bus_cpu_lv1} = cpu_lv1_if_data_in_bus_cpu_lv1;

    // instantiate DUT (L1 and L2)
    cache_top inst_cache_top (
                                .clk(clk),
                                .data_bus_cpu_lv1_0     (inst_cpu_lv1_if[0].data_bus_cpu_lv1              ),
                                .addr_bus_cpu_lv1_0     (inst_cpu_lv1_if[0].addr_bus_cpu_lv1              ),
                                .data_bus_cpu_lv1_1     (inst_cpu_lv1_if[1].data_bus_cpu_lv1              ),
                                .addr_bus_cpu_lv1_1     (inst_cpu_lv1_if[1].addr_bus_cpu_lv1              ),
                                .data_bus_cpu_lv1_2     (inst_cpu_lv1_if[2].data_bus_cpu_lv1              ),
                                .addr_bus_cpu_lv1_2     (inst_cpu_lv1_if[2].addr_bus_cpu_lv1              ),
                                .data_bus_cpu_lv1_3     (inst_cpu_lv1_if[3].data_bus_cpu_lv1              ),
                                .addr_bus_cpu_lv1_3     (inst_cpu_lv1_if[3].addr_bus_cpu_lv1              ),
                                .cpu_rd                 (cpu_lv1_if_cpu_rd                          ),
                                .cpu_wr                 (cpu_lv1_if_cpu_wr                          ),
                                .cpu_wr_done            (cpu_lv1_if_cpu_wr_done                     ),
                                .bus_lv1_lv2_gnt_proc   (inst_system_bus_if.bus_lv1_lv2_gnt_proc    ),
                                .bus_lv1_lv2_req_proc   (inst_system_bus_if.bus_lv1_lv2_req_proc    ),
                                .bus_lv1_lv2_gnt_snoop  (inst_system_bus_if.bus_lv1_lv2_gnt_snoop   ),
                                .bus_lv1_lv2_req_snoop  (inst_system_bus_if.bus_lv1_lv2_req_snoop   ),
                                .data_in_bus_cpu_lv1    (cpu_lv1_if_data_in_bus_cpu_lv1             ),
                                .data_bus_lv2_mem       (data_bus_lv2_mem                           ),
                                .addr_bus_lv2_mem       (addr_bus_lv2_mem                           ),
                                .mem_rd                 (mem_rd                                     ),
                                .mem_wr                 (mem_wr                                     ),
                                .mem_wr_done            (mem_wr_done                                ),
                                .bus_lv1_lv2_gnt_lv2    (inst_system_bus_if.bus_lv1_lv2_gnt_lv2     ),
                                .bus_lv1_lv2_req_lv2    (inst_system_bus_if.bus_lv1_lv2_req_lv2     ),
                                .data_in_bus_lv2_mem    (data_in_bus_lv2_mem                        )
                            );

    // System clock generation
    initial begin
        clk = 1'b0;
        forever
            #5 clk = ~clk;
    end

    // TB inital setup
    initial begin
        `uvm_info("TOP","Starting UVM test", UVM_LOW)
        uvm_config_db#(virtual interface cpu_lv1_interface)::set(null,"*.tb.cpu[0].*","vif",inst_cpu_lv1_if[0]);
        uvm_config_db#(virtual interface cpu_lv1_interface)::set(null,"*.tb.cpu[1].*","vif",inst_cpu_lv1_if[1]);
        uvm_config_db#(virtual interface cpu_lv1_interface)::set(null,"*.tb.cpu[2].*","vif",inst_cpu_lv1_if[2]);
        uvm_config_db#(virtual interface cpu_lv1_interface)::set(null,"*.tb.cpu[3].*","vif",inst_cpu_lv1_if[3]);
        uvm_config_db#(virtual interface system_bus_interface)::set(null,"*.tb.*","v_sbus_if",inst_system_bus_if);
        uvm_config_db#(virtual interface cpu_mesi_lru_interface)::set(null,"*.tb.cpu[0].*","v_mesi_lru_if",inst_cpu_mesi_lru_if[0]);
        uvm_config_db#(virtual interface cpu_mesi_lru_interface)::set(null,"*.tb.cpu[1].*","v_mesi_lru_if",inst_cpu_mesi_lru_if[1]);
        uvm_config_db#(virtual interface cpu_mesi_lru_interface)::set(null,"*.tb.cpu[2].*","v_mesi_lru_if",inst_cpu_mesi_lru_if[2]);
        uvm_config_db#(virtual interface cpu_mesi_lru_interface)::set(null,"*.tb.cpu[3].*","v_mesi_lru_if",inst_cpu_mesi_lru_if[3]);
        run_test();
        `uvm_info("TOP", "DONE", UVM_LOW)
    end

endmodule
