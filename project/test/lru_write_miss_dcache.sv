//=====================================================================
// Project: 4 core MESI cache design
// File Name: lru_write_miss_dcache.sv
// Description: Test for lru write-miss operation on D-cache
// Designers: Venky & Suru
//=====================================================================

class lru_write_miss_dcache extends base_test;

    //component macro
    `uvm_component_utils(lru_write_miss_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lru_write_miss_dcache_seq::type_id::get());
        // randomize the case type
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lru_write_miss_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : lru_write_miss_dcache

// Sequence for lru write-miss operation on D-cache
class lru_write_miss_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lru_write_miss_dcache_seq)

    cpu_transaction_c trans;
    // random index
    rand bit [`INDEX_MSB_LV1:`INDEX_LSB_LV1] rand_index;
    // 5 random tag values
    rand bit [`TAG_MSB_LV1:`TAG_LSB_LV1] rand_tag[5];
    // random offset bits
    rand bit [`OFFSET_MSB_LV1:`OFFSET_LSB_LV1] rand_offset[5];
    // Constraint for 5 unique tags for D-cache accesses
    constraint c_tag_icache{
        foreach(rand_tag[i])
            rand_tag[i][`TAG_MSB_LV1:`TAG_MSB_LV1-1] != 'b0;
        unique{rand_tag};
    }

    //constructor
    function new (string name="lru_write_miss_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        // generate 6 random read/write requests from the address generated
        repeat (6)
        begin
            if (!(rand_num_idx.randomize())) `uvm_error(get_type_name(), "Randomize error on rand_num_idx");

            //`uvm_info(get_type_name(), $sformatf("IDX picked %d",rand_num_idx.idx), UVM_LOW)
            //`uvm_info(get_type_name(), $sformatf("Address generated is: %h",{rand_tag[rand_num_idx.idx],rand_index,rand_offset[rand_num_idx.idx]}), UVM_LOW)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {access_cache_type == DCACHE_ACC; address == {rand_tag[rand_num_idx.idx],rand_index,rand_offset[rand_num_idx.idx]};})
        end

        // let last 4 accesses be write requests to the address generated
        repeat (4)
        begin
            if (!(rand_num_idx.randomize())) `uvm_error(get_type_name(), "Randomize error on rand_num_idx");

            //`uvm_info(get_type_name(), $sformatf("IDX picked %d",rand_num_idx.idx), UVM_LOW)
            //`uvm_info(get_type_name(), $sformatf("request_type == WRITE_REQ Address generated is: %h",{rand_tag[rand_num_idx.idx],rand_index,rand_offset[rand_num_idx.idx]}), UVM_LOW)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ;access_cache_type == DCACHE_ACC; address == {rand_tag[rand_num_idx.idx],rand_index,rand_offset[rand_num_idx.idx]};})
        end
    endtask

endclass : lru_write_miss_dcache_seq
