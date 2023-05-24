//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_hit_dcache.sv
// Description: Test for read-hit to D-cache
// Designers: Venky & Suru
//=====================================================================
typedef enum {PROC_IN_E = 0, PROC_IN_M = 1, PROC_IN_S = 2} case_rhd_t;

class read_hit_dcache extends base_test;

    //component macro
    `uvm_component_utils(read_hit_dcache)

    case_rhd_t case_rhd_type;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_hit_dcache_seq::type_id::get());
        if(clp.get_arg_value("PROC_IN=", temp_string))begin
            case_rhd_type = temp_string.atoi();
        end else if (!std::randomize(case_rhd_type)) `uvm_error(get_type_name(), "Randomize error on case_rhd_type");
        uvm_config_db#(case_rhd_t)::set(this,"tb.vsequencer.read_hit_dcache_seq","case_rhd_type",case_rhd_type);
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_hit_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : read_hit_dcache


// Sequence for a read-hit to D-cache
class read_hit_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_hit_dcache_seq)

    cpu_transaction_c trans;
    rand case_rhd_t case_rhd_type;
    bit [`ADDR_WID_LV1-1 : 0]   access_address;

    //constructor
    function new (string name="read_hit_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        uvm_config_db#(case_rhd_t)::get(null,get_full_name(),"case_rhd_type", case_rhd_type);
        `uvm_info(get_type_name(), $sformatf("Case to run is %s",case_rhd_type.name()), UVM_LOW)

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        access_address = trans.address;

        // for putting proc cache in different states
        //if (case_rhd_type == PROC_IN_E)
            // Do nothing
        if (case_rhd_type == PROC_IN_S)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        else if (case_rhd_type == PROC_IN_M)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
    endtask

endclass : read_hit_dcache_seq
