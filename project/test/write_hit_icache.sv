//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_hit_icache.sv
// Description: Test for write-hit to I-cache
// Designers: Venky & Suru
//=====================================================================

class write_hit_icache extends base_test;

    //component macro
    `uvm_component_utils(write_hit_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_hit_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_hit_icache test" , UVM_LOW)
    endtask: run_phase

endclass : write_hit_icache


// Sequence for a write hit on I-cache
class write_hit_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_hit_icache_seq)

    cpu_transaction_c           trans;
    bit [`ADDR_WID_LV1-1 : 0]   access_address;

    //constructor
    function new (string name="write_hit_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;})
        access_address = trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC; address == access_address;})
    endtask

endclass : write_hit_icache_seq