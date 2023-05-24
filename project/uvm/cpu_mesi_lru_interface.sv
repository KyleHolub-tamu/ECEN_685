//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_mesi_lru_interface.sv
// Description: Basic interface for CPU MESI state and LRU replacement
//              signals of both I/D-cache
// Designers: Venky & Suru
//=====================================================================

interface cpu_mesi_lru_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter MESI_WID_LV1  = `MESI_WID_LV1;
    parameter ASSOC_WID_LV1 = `ASSOC_WID_LV1;

    // Proc and Snoop side MESI state for the cache set accessed
    wire [MESI_WID_LV1 - 1 : 0] current_mesi_proc;
    wire [MESI_WID_LV1 - 1 : 0] current_mesi_snoop;
    wire [MESI_WID_LV1 - 1 : 0] updated_mesi_proc;
    wire [MESI_WID_LV1 - 1 : 0] updated_mesi_snoop;

    wire cpu_rd;
    wire cpu_wr;
    wire bus_rd;
    wire bus_rdx;
    wire invalidate;

    wire [ASSOC_WID_LV1 - 1 : 0] lru_replacement_proc_dl;
    wire [ASSOC_WID_LV1 - 1 : 0] lru_replacement_proc_il;

    wire [ASSOC_WID_LV1 - 1 : 0] blk_accessed_main_dl;
    wire [ASSOC_WID_LV1 - 1 : 0] blk_accessed_main_il;

    wire lru_update_dl;
    wire lru_update_il;

    parameter INVALID   = 2'b00;
    parameter SHARED    = 2'b01;
    parameter EXCLUSIVE = 2'b10;
    parameter MODIFIED  = 2'b11;
    
    covergroup cover_current_mesi_state @(posedge clk);
        option.per_instance = 1;
        cov_proc_state: coverpoint current_mesi_proc iff (cpu_rd || cpu_wr) {
            bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;
        }
        cov_snoop_state: coverpoint current_mesi_snoop iff (bus_rd || bus_rdx || invalidate) {
            bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;
        }
    endgroup

    covergroup cover_updated_mesi_state @(posedge clk);
        option.per_instance = 1;
        cov_proc_state: coverpoint updated_mesi_proc iff (cpu_rd || cpu_wr) {
            ignore_bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;
        }
        cov_snoop_state: coverpoint updated_mesi_snoop iff (bus_rd || bus_rdx || invalidate) {
            bins BIN_INVALID   = INVALID;
            bins BIN_SHARED    = SHARED;
            bins BIN_EXCLUSIVE = EXCLUSIVE;
            bins BIN_MODIFIED  = MODIFIED;
        }
    endgroup
    
    cover_current_mesi_state inst_cover_current_mesi_state = new();
    cover_updated_mesi_state inst_cover_updated_mesi_state = new();

    covergroup cover_mesi_proc_trans @(posedge clk);
        option.per_instance = 1;
        cov_proc_trans: coverpoint updated_mesi_proc iff (cpu_rd || cpu_wr) {
            ignore_bins BIN_INV_INV = INVALID iff (current_mesi_proc == INVALID);
            bins BIN_INV_SHR = SHARED iff (current_mesi_proc == INVALID);
            bins BIN_INV_EXC = EXCLUSIVE iff (current_mesi_proc == INVALID);
            bins BIN_INV_MOD = MODIFIED iff (current_mesi_proc == INVALID);
            ignore_bins BIN_SHR_INV = INVALID iff (current_mesi_proc == SHARED);
            ignore_bins BIN_SHR_SHR = SHARED iff (current_mesi_proc == SHARED);
            ignore_bins BIN_SHR_EXC = EXCLUSIVE iff (current_mesi_proc == SHARED);
            ignore_bins BIN_SHR_MOD = MODIFIED iff (current_mesi_proc == SHARED);
            ignore_bins BIN_EXC_INV = INVALID iff (current_mesi_proc == EXCLUSIVE);
            ignore_bins BIN_EXC_SHR = SHARED iff (current_mesi_proc == EXCLUSIVE);
            ignore_bins BIN_EXC_EXC = EXCLUSIVE iff (current_mesi_proc == EXCLUSIVE);
            ignore_bins BIN_EXC_MOD = MODIFIED iff (current_mesi_proc == EXCLUSIVE);
            ignore_bins BIN_MOD_INV = INVALID iff (current_mesi_proc == MODIFIED);
            ignore_bins BIN_MOD_SHR = SHARED iff (current_mesi_proc == MODIFIED);
            ignore_bins BIN_MOD_EXC = EXCLUSIVE iff (current_mesi_proc == MODIFIED);
            ignore_bins BIN_MOD_MOD = MODIFIED iff (current_mesi_proc == MODIFIED);
        }
    endgroup

    covergroup cover_mesi_snoop_trans @(posedge clk);
        option.per_instance = 1;
        cov_snoop_trans: coverpoint updated_mesi_snoop iff (cpu_rd || cpu_wr) {
            ignore_bins BIN_INV_INV = INVALID iff (current_mesi_snoop == INVALID);
            ignore_bins BIN_INV_SHR = SHARED iff (current_mesi_snoop == INVALID);
            ignore_bins BIN_INV_EXC = EXCLUSIVE iff (current_mesi_snoop == INVALID);
            ignore_bins BIN_INV_MOD = MODIFIED iff (current_mesi_snoop == INVALID);
            bins BIN_SHR_INV = INVALID iff (current_mesi_snoop == SHARED);
            bins BIN_SHR_SHR = SHARED iff (current_mesi_snoop == SHARED);
            bins BIN_SHR_EXC = EXCLUSIVE iff (current_mesi_snoop == SHARED);
            bins BIN_SHR_MOD = MODIFIED iff (current_mesi_snoop == SHARED);
            bins BIN_EXC_INV = INVALID iff (current_mesi_snoop == EXCLUSIVE);
            bins BIN_EXC_SHR = SHARED iff (current_mesi_snoop == EXCLUSIVE);
            bins BIN_EXC_EXC = EXCLUSIVE iff (current_mesi_snoop == EXCLUSIVE);
            bins BIN_EXC_MOD = MODIFIED iff (current_mesi_snoop == EXCLUSIVE);
            bins BIN_MOD_INV = INVALID iff (current_mesi_snoop == MODIFIED);
            bins BIN_MOD_SHR = SHARED iff (current_mesi_snoop == MODIFIED);
            bins BIN_MOD_EXC = EXCLUSIVE iff (current_mesi_snoop == MODIFIED);
            bins BIN_MOD_MOD = MODIFIED iff (current_mesi_snoop == MODIFIED);
        }
    endgroup
    
    cover_mesi_proc_trans  inst_cover_mesi_proc_trans = new();
    cover_mesi_snoop_trans inst_cover_mesi_snoop_trans = new();

    parameter SET0 = 2'b00;
    parameter SET1 = 2'b01;
    parameter SET2 = 2'b10;
    parameter SET3 = 2'b11;
    
    covergroup cover_lru_state @(posedge clk);
        option.per_instance = 1;
        cov_lru_replace_dl: coverpoint lru_replacement_proc_dl {
            bins BIN_SET0 = SET0;
            bins BIN_SET1 = SET1;
            bins BIN_SET2 = SET2;
            bins BIN_SET3 = SET3;
        }
        cov_lru_replace_il: coverpoint lru_replacement_proc_il {
            bins BIN_SET0 = SET0;
            bins BIN_SET1 = SET1;
            bins BIN_SET2 = SET2;
            bins BIN_SET3 = SET3;
        }
        cov_blk_accessed_dl: coverpoint blk_accessed_main_dl iff (lru_update_dl) {
            bins BIN_SET0 = SET0;
            bins BIN_SET1 = SET1;
            bins BIN_SET2 = SET2;
            bins BIN_SET3 = SET3;
        }
        cov_blk_accessed_il: coverpoint blk_accessed_main_il iff (lru_update_il) {
            bins BIN_SET0 = SET0;
            bins BIN_SET1 = SET1;
            bins BIN_SET2 = SET2;
            bins BIN_SET3 = SET3;
        }
    endgroup
    
    cover_lru_state inst_cover_lru_state = new();

    covergroup cover_lru_trans @(posedge clk);
        option.per_instance = 1;
        cov_lru_trans_dl: coverpoint lru_replacement_proc_dl {
            bins BIN_SET0_SET0 = (SET0 => SET0);
            bins BIN_SET0_SET1 = (SET0 => SET1);
            bins BIN_SET0_SET2 = (SET0 => SET2);
            bins BIN_SET0_SET3 = (SET0 => SET3);
            bins BIN_SET1_SET0 = (SET1 => SET0);
            bins BIN_SET1_SET1 = (SET1 => SET1);
            bins BIN_SET1_SET2 = (SET1 => SET2);
            bins BIN_SET1_SET3 = (SET1 => SET3);
            bins BIN_SET2_SET0 = (SET2 => SET0);
            bins BIN_SET2_SET1 = (SET2 => SET1);
            bins BIN_SET2_SET2 = (SET2 => SET2);
            bins BIN_SET2_SET3 = (SET2 => SET3);
            bins BIN_SET3_SET0 = (SET3 => SET0);
            bins BIN_SET3_SET1 = (SET3 => SET1);
            bins BIN_SET3_SET2 = (SET3 => SET2);
            bins BIN_SET3_SET3 = (SET3 => SET3);
        }
        cov_lru_trans_il: coverpoint lru_replacement_proc_il {
            bins BIN_SET0_SET0 = (SET0 => SET0);
            bins BIN_SET0_SET1 = (SET0 => SET1);
            bins BIN_SET0_SET2 = (SET0 => SET2);
            bins BIN_SET0_SET3 = (SET0 => SET3);
            bins BIN_SET1_SET0 = (SET1 => SET0);
            bins BIN_SET1_SET1 = (SET1 => SET1);
            bins BIN_SET1_SET2 = (SET1 => SET2);
            bins BIN_SET1_SET3 = (SET1 => SET3);
            bins BIN_SET2_SET0 = (SET2 => SET0);
            bins BIN_SET2_SET1 = (SET2 => SET1);
            bins BIN_SET2_SET2 = (SET2 => SET2);
            bins BIN_SET2_SET3 = (SET2 => SET3);
            bins BIN_SET3_SET0 = (SET3 => SET0);
            bins BIN_SET3_SET1 = (SET3 => SET1);
            bins BIN_SET3_SET2 = (SET3 => SET2);
            bins BIN_SET3_SET3 = (SET3 => SET3);
        }
    endgroup
    
    cover_lru_trans  inst_cover_lru_trans = new();

endinterface
