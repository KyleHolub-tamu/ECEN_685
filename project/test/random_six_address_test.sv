//=====================================================================
// Project: 4 core MESI cache design
// File Name: random_six_address_test.sv
// Description: Test for checking the behavior of the core for 100 random read/write
//              requests to addresses within two set indices in I/D cache for 4 cores
// Designers: Venky & Suru
//=====================================================================

class random_six_address_test extends base_test;

    //component macro
    `uvm_component_utils(random_six_address_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", random_six_address_vseq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing random_six_address_test" , UVM_LOW)
    endtask: run_phase

endclass : random_six_address_test

// Sequence for checking the behavior of the core for 100 random read/write requests
// to 6 limited addresses in I/D cache for 4 cores
class random_six_address_vseq extends base_vseq;
    //object macro
    `uvm_object_utils(random_six_address_vseq)

    six_addr_random_seq seq0, seq1, seq2, seq3;
    rand bit [29 : 0]  six_addrt[6];
    rand bit [13 : 0]  set_indext;
    //rand bit D_only, I_only;

    constraint c_same_index{
        foreach (six_addrt[i]){
            six_addrt[i][13:0] == set_indext;
            //D_only == 1 -> { six_addrt[i][30:29] != 2'b00;}
            //I_only == 1 -> { six_addrt[i][30:29] == 2'b00;}
        }
    }

    //choose one or none of D_only and I_only
    //constraint c_d_i_only{
    //    if(D_only){
    //        I_only == 0;
    //    }
    //}

    //constructor
    function new (string name="random_six_address_vseq");
        super.new(name);
    endfunction : new

    virtual task body();
        // initiate hundred random requests on CPU0, CPU1, CPU2, CPU3 simultaneously
        `uvm_info(get_type_name(), $sformatf("Six Address[0] = %x", six_addrt[0]),UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Six Address[1] = %x", six_addrt[1]),UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Six Address[2] = %x", six_addrt[2]),UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Six Address[3] = %x", six_addrt[3]),UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Six Address[4] = %x", six_addrt[4]),UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Six Address[5] = %x", six_addrt[5]),UVM_LOW)
        fork
            `uvm_do_on_with(seq0, p_sequencer.cpu_seqr[0], {six_addr[0] == six_addrt[0]; six_addr[1] == six_addrt[1];six_addr[2] == six_addrt[2];six_addr[3] == six_addrt[3]; six_addr[4] == six_addrt[4];six_addr[5] == six_addrt[5]; wait_time_max == 30;})
            `uvm_do_on_with(seq1, p_sequencer.cpu_seqr[1], {six_addr[0] == six_addrt[0]; six_addr[1] == six_addrt[1];six_addr[2] == six_addrt[2];six_addr[3] == six_addrt[3]; six_addr[4] == six_addrt[4];six_addr[5] == six_addrt[5]; wait_time_max == 30;})
            `uvm_do_on_with(seq2, p_sequencer.cpu_seqr[2], {six_addr[0] == six_addrt[0]; six_addr[1] == six_addrt[1];six_addr[2] == six_addrt[2];six_addr[3] == six_addrt[3]; six_addr[4] == six_addrt[4];six_addr[5] == six_addrt[5]; wait_time_max == 30;})
            `uvm_do_on_with(seq3, p_sequencer.cpu_seqr[3], {six_addr[0] == six_addrt[0]; six_addr[1] == six_addrt[1];six_addr[2] == six_addrt[2];six_addr[3] == six_addrt[3]; six_addr[4] == six_addrt[4];six_addr[5] == six_addrt[5]; wait_time_max == 30;})
        join

    endtask

endclass : random_six_address_vseq
