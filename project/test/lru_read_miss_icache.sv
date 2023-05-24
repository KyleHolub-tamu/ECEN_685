//=====================================================================
// Project: 4 core MESI cache design
// File Name: lru_read_miss_icache.sv
// Description: Test for lru read-miss operation on I-cache
// Designers: Venky & Suru
//=====================================================================

class lru_read_miss_icache extends base_test;

    //component macro
    `uvm_component_utils(lru_read_miss_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lru_read_miss_icache_seq::type_id::get());
        // randomize the case type
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lru_read_miss_icache test" , UVM_LOW)
    endtask: run_phase

endclass : lru_read_miss_icache

// Sequence for lru read-miss operation on I-cache
class lru_read_miss_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lru_read_miss_icache_seq)

    cpu_transaction_c trans;
    // random index
    rand bit [`INDEX_MSB_LV1:`INDEX_LSB_LV1] rand_index;
    // 5 random tag values
    rand bit [`TAG_MSB_LV1:`TAG_LSB_LV1] rand_tag[5];
    // random offset bits
    rand bit [`OFFSET_MSB_LV1:`OFFSET_LSB_LV1] rand_offset[5];
    // randomize pick
    randc bit [2:0] idx;

    // Constraint for 5 unique tags for I-cache accesses
    constraint c_tag_icache{
        foreach(rand_tag[i])
            rand_tag[i][`TAG_MSB_LV1:`TAG_MSB_LV1-1] == 'b0;
        unique{rand_tag};
    }

    //constructor
    function new (string name="lru_read_miss_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        // generate 10 random read requests from the address generated
        repeat (10)
        begin
            if (!(rand_num_idx.randomize())) `uvm_error(get_type_name(), "Randomize error on rand_num_idx");

            //`uvm_info(get_type_name(), $sformatf("IDX picked %d",rand_num_idx.idx), UVM_LOW)
            //`uvm_info(get_type_name(), $sformatf("Address generated is: %h",{rand_tag[rand_num_idx.idx],rand_index,rand_offset[rand_num_idx.idx]}), UVM_LOW)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == {rand_tag[rand_num_idx.idx],rand_index,rand_offset[rand_num_idx.idx]};})
        end

    endtask

endclass : lru_read_miss_icache_seq
