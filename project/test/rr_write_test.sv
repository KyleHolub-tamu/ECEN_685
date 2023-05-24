//=====================================================================
// Project: 4 core MESI cache design
// File Name: rr_write_test.sv
// Description: Test for checking the behavior of the 4-cores for round-robin write requests to D-cache
// Designers: Venky & Suru
//=====================================================================

class rr_write_test extends base_test;

    //component macro
    `uvm_component_utils(rr_write_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", rr_write_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing rr_write_test test" , UVM_LOW)
    endtask: run_phase

endclass : rr_write_test


// Sequence for checking the behavior of the core for a snoop invalidate request
class rr_write_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(rr_write_test_seq)

    rand bit [`ADDR_WID_LV1-1 : 0]  access_address;

    //constructor
    function new (string name="rr_write_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        // generate a access_address for D-cache space
        if (!(std::randomize(access_address) with {access_address > `IL_DL_ADDR_BOUND;})) `uvm_error(get_type_name(), "Randomize error on access_address");

        // sequences of accesses for a round-robin test to D-cache
        // Read 0, Read 1, Read 2, Read 3
        do_on_cpu(CORE0,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE1,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE2,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE3,READ_REQ,access_address,RAND_WAIT,0);
        // Write 0, Read 1, Write 2, Read 3
        do_on_cpu(CORE0,WRITE_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE1,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE2,WRITE_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE3,READ_REQ,access_address,RAND_WAIT,0);
        // Write 1, Read 0, Write 3, Read 2
        do_on_cpu(CORE1,WRITE_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE0,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE3,WRITE_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE2,READ_REQ,access_address,RAND_WAIT,0);
        // Write 0, Write 1, Write 2, Write 3
        do_on_cpu(CORE0,WRITE_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE1,WRITE_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE2,WRITE_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE3,WRITE_REQ,access_address,RAND_WAIT,0);
        // Read 0, Read 1, Read 2, Read 3
        do_on_cpu(CORE0,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE1,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE2,READ_REQ,access_address,RAND_WAIT,0);
        do_on_cpu(CORE3,READ_REQ,access_address,RAND_WAIT,0);

    endtask

endclass : rr_write_test_seq
