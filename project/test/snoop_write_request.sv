//=====================================================================
// Project: 4 core MESI cache design
// File Name: snoop_write_request.sv
// Description: Test for checking the behavior of the core for a snoop write request
// Designers: Venky & Suru
//=====================================================================
typedef enum {CPU0_IN_I_SWRREQ = 0, CPU0_IN_E_SWRREQ = 1, CPU0_IN_M_SWRREQ = 2, CPU0_IN_S_SWRREQ = 3} case_swrreq_t;

class snoop_write_request extends base_test;

    //component macro
    `uvm_component_utils(snoop_write_request)

    case_swrreq_t case_swrreq_type;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", snoop_write_request_seq::type_id::get());
        if(clp.get_arg_value("+CPU0_IN=", temp_string))begin
            case_swrreq_type = temp_string.atoi();
        end else if (!std::randomize(case_swrreq_type)) `uvm_error(get_type_name(), "Randomize error on case_swrreq_type");
        uvm_config_db#(case_swrreq_t)::set(this,"tb.vsequencer.snoop_write_request_seq","case_swrreq_type",case_swrreq_type);
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing snoop_write_request test" , UVM_LOW)
    endtask: run_phase

endclass : snoop_write_request


// Sequence for checking the behavior of the core for a snoop write request
class snoop_write_request_seq extends base_vseq;
    //object macro
    `uvm_object_utils(snoop_write_request_seq)

    cpu_transaction_c trans;
    rand case_swrreq_t case_swrreq_type;
    rand bit [`ADDR_WID_LV1-1 : 0]  access_address;

    //constructor
    function new (string name="snoop_write_request_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        uvm_config_db#(case_swrreq_t)::get(null,get_full_name(),"case_swrreq_type", case_swrreq_type);
        `uvm_info(get_type_name(), $sformatf("Case to run is %s",case_swrreq_type.name()), UVM_LOW)

        // randomize the access_address with constraints for D-cache access
        if (!(std::randomize(access_address) with {access_address > `IL_DL_ADDR_BOUND;})) `uvm_error(get_type_name(), "Randomize error on access_address");

        // setup the cpu0 for the initial state (do nothing for CPU0_IN_I_SWRREQ)
        if (case_swrreq_type == CPU0_IN_E_SWRREQ)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        else if (case_swrreq_type == CPU0_IN_M_SWRREQ)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        else if (case_swrreq_type == CPU0_IN_S_SWRREQ)
        begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            // evict the block from core1 by performing 4 random access to blocks mapping to the same set
            repeat(4) begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {access_cache_type == DCACHE_ACC; address[`INDEX_MSB_LV1:`INDEX_LSB_LV1] == access_address[`INDEX_MSB_LV1:`INDEX_LSB_LV1]; address != access_address;})
            end
        end

        // initiate a write request to the same access_address on core 1
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

        // do appropriate operation to confirm the cpu0 has updated the mesi state of the block
        // if it was in I: read to block in CPU0. Now it is expected to receive the block from CPU1
        // cp_in_cache and shared is expected to be raised for all the cases
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

    endtask

endclass : snoop_write_request_seq
