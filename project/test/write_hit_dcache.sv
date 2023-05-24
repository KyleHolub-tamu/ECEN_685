//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_hit_dcache.sv
// Description: Test for write-hit to D-cache
// Designers: Venky & Suru
//=====================================================================
typedef enum {PROC_IN_E_WHD = 1, PROC_IN_M_WHD = 2, PROC_IN_S_WHD = 3} case_whd_t;

class write_hit_dcache extends base_test;

    //component macro
    `uvm_component_utils(write_hit_dcache)

    rand case_whd_t case_whd_type;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_hit_dcache_seq::type_id::get());
        // randomize the case type
        if (!std::randomize(case_whd_type)) `uvm_error(get_type_name(), "Randomize error on case_whd_type");
        uvm_config_db#(case_whd_t)::set(this,"tb.vsequencer.write_hit_dcache_seq","case_whd_type",case_whd_type);
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_hit_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : write_hit_dcache


// Sequence for a write-hit to D-cache
class write_hit_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_hit_dcache_seq)

    cpu_transaction_c trans;
    rand case_whd_t case_whd_type;
    rand bit [`ADDR_WID_LV1-1 : 0]  access_address;

    //constructor
    function new (string name="write_hit_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        uvm_config_db#(case_whd_t)::get(null,get_full_name(),"case_whd_type", case_whd_type);
        `uvm_info(get_type_name(), $sformatf("Case to run is %s",case_whd_type.name()), UVM_LOW)

        // randomize the access_address with constraints for D-cache access
        if (!(std::randomize(access_address) with {access_address > `IL_DL_ADDR_BOUND;})) `uvm_error(get_type_name(), "Randomize error on access_address");

        // setup the proc for the initial state
        if (case_whd_type == PROC_IN_E_WHD)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        else if (case_whd_type == PROC_IN_M_WHD)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        else if (case_whd_type == PROC_IN_S_WHD)
        begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        end

        // initiate a write request to the same access_address on core 0
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

        // read back to ensure data integrity
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

    endtask

endclass : write_hit_dcache_seq
