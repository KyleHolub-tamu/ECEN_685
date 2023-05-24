//=====================================================================
// Project: 4 core MESI cache design
// File Name: random_delay_test.sv
// Description: Test for checking the behavior of the core for 100 random read/write
//              requests to addresses within two set indices in I/D cache for 4 cores
//              Delay between the start of requests on each core
// Designers: Venky & Suru
//=====================================================================

class random_delay_test extends base_test;

    //component macro
    `uvm_component_utils(random_delay_test)

    case_sinvreq_t case_sinvreq_type;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", random_delay_vseq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing random_delay_test" , UVM_LOW)
    endtask: run_phase

endclass : random_delay_test

// Sequence for checking the behavior of the core for 100 random read/write requests
// to addresses within two set indices in I/D cache for 4 cores
// Delay between the start of requests on each core
class random_delay_vseq extends base_vseq;
    //object macro
    `uvm_object_utils(random_delay_vseq)

    hundred_random_seq seq0, seq1, seq2, seq3;
    rand bit [13 : 0]  indext[2];

    //constructor
    function new (string name="random_delay_vseq");
        super.new(name);
    endfunction : new

    virtual task body();
        // initiate hundred random requests on CPU0, CPU1, CPU2, CPU3 simultaneously
        fork
            `uvm_do_on_with(seq0, p_sequencer.cpu_seqr[0], {index[0] == indext[0]; index[1] == indext[1];})
            `uvm_do_on_with(seq1, p_sequencer.cpu_seqr[1], {index[0] == indext[0]; index[1] == indext[1];})
            `uvm_do_on_with(seq2, p_sequencer.cpu_seqr[2], {index[0] == indext[0]; index[1] == indext[1];})
            `uvm_do_on_with(seq3, p_sequencer.cpu_seqr[3], {index[0] == indext[0]; index[1] == indext[1];})
        join

    endtask

endclass : random_delay_vseq
