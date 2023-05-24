//=====================================================================
// Project: 4 core MESI cache design
// File Name: simul_read_test.sv
// Description: Test for checking the behavior of the 4-cores for simultaneous read requests
// Designers: Venky & Suru
//=====================================================================

class simul_read_test extends base_test;

    //component macro
    `uvm_component_utils(simul_read_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", simul_read_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing simul_read_test test" , UVM_LOW)
    endtask: run_phase

endclass : simul_read_test


// Sequence for checking the behavior of the 4-cores for simultaneous read requests
class simul_read_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(simul_read_test_seq)

    rand bit [`ADDR_WID_LV1-1 : 0]  access_address;

    //constructor
    function new (string name="simul_read_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        // generate a access_address for I-cache space
        if (!(std::randomize(access_address) with {access_address <= `IL_DL_ADDR_BOUND;})) `uvm_error(get_type_name(), "Randomize error on access_address");

        // simultaneous reads for the I-cache address on 4 cores - wait_cycles = 0
        fork
            do_on_cpu(CORE0,READ_REQ,access_address,FIX_WAIT,0);
            do_on_cpu(CORE1,READ_REQ,access_address,FIX_WAIT,0);
            do_on_cpu(CORE2,READ_REQ,access_address,FIX_WAIT,0);
            do_on_cpu(CORE3,READ_REQ,access_address,FIX_WAIT,0);
        join

        // generate a access_address for D-cache space
        if (!(std::randomize(access_address) with {access_address > `IL_DL_ADDR_BOUND;})) `uvm_error(get_type_name(), "Randomize error on access_address");

        // simultaneous reads for the D-cache address on 4 cores - wait_cycles = 50
        fork
            do_on_cpu(CORE0,READ_REQ,access_address,FIX_WAIT,50);
            do_on_cpu(CORE1,READ_REQ,access_address,FIX_WAIT,50);
            do_on_cpu(CORE2,READ_REQ,access_address,FIX_WAIT,50);
            do_on_cpu(CORE3,READ_REQ,access_address,FIX_WAIT,50);
        join

    endtask

endclass : simul_read_test_seq
