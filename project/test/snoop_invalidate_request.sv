//=====================================================================
// Project: 4 core MESI cache design
// File Name: snoop_invalidate_request.sv
// Description: Test for checking the behavior of the core for a snoop invalidate request
// Designers: Venky & Suru
//=====================================================================
typedef enum {CPU0_NO_SINVREQ = 0, CPU0_IN_S_SINVREQ = 1, CPU0_CPLX_SINVREQ = 2} case_sinvreq_t;

class snoop_invalidate_request extends base_test;

    //component macro
    `uvm_component_utils(snoop_invalidate_request)

    case_sinvreq_t case_sinvreq_type;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", snoop_invalidate_request_seq::type_id::get());
        if(clp.get_arg_value("+CPU0_IN=", temp_string))begin
            case_sinvreq_type = temp_string.atoi();
        end else if (!std::randomize(case_sinvreq_type)) `uvm_error(get_type_name(), "Randomize error on case_sinvreq_type");
        uvm_config_db#(case_sinvreq_t)::set(this,"tb.vsequencer.snoop_invalidate_request_seq","case_sinvreq_type",case_sinvreq_type);
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing snoop_invalidate_request test" , UVM_LOW)
    endtask: run_phase

endclass : snoop_invalidate_request


// Sequence for checking the behavior of the core for a snoop invalidate request
class snoop_invalidate_request_seq extends base_vseq;
    //object macro
    `uvm_object_utils(snoop_invalidate_request_seq)

    cpu_transaction_c trans, trans2;
    rand case_sinvreq_t case_sinvreq_type;
    rand bit [`ADDR_WID_LV1-1 : 0]  access_address;
    rand bit [`ADDR_WID_LV1-1 : 0]  access_address2;

    //constructor
    function new (string name="snoop_invalidate_request_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        uvm_config_db#(case_sinvreq_t)::get(null,get_full_name(),"case_sinvreq_type", case_sinvreq_type);
        `uvm_info(get_type_name(), $sformatf("Case to run is %s",case_sinvreq_type.name()), UVM_LOW)

        // randomize the access_address with constraints for D-cache access
        if (!(std::randomize(access_address) with {access_address > `IL_DL_ADDR_BOUND;})) `uvm_error(get_type_name(), "Randomize error on access_address");

        // initiate a read request to the same access_address on core 1 and 0
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

        // setup the cpu0 for the initial state (do nothing for CPU0_IN_S_SINVREQ)
        if (case_sinvreq_type == CPU0_NO_SINVREQ)
        begin
            // evict the block from core0 by performing 4 random access to blocks mapping to the same set
            repeat(4) begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {access_cache_type == DCACHE_ACC; address[`INDEX_MSB_LV1:`INDEX_LSB_LV1] == access_address[`INDEX_MSB_LV1:`INDEX_LSB_LV1]; address != access_address;})
            end
        end
        else if (case_sinvreq_type == CPU0_CPLX_SINVREQ)
        begin
            // write to block B, not same as address B
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address != access_address;})
            access_address2 = trans.address;

            // fork issue write to A and read to B from CPU1 and 0 within 1 cycle delay
            fork
                begin
                    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
                end
                begin
                    #30;
                    `uvm_do_on_with(trans2, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address2;})
                end
            join_any

            // block A is assumed to be in M, so write new data. Read it back from CPU0
            // block A read again from CPU1
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            return;
        end

        // initiate a write/read request to the same access_address on core 1
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

        // do appropriate operation to confirm the cpu0 has updated the mesi state of the block
        // write to block in CPU0. Now it is expected to send a bus_rdx and dirty block on snoop should be return back to L2
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

    endtask

endclass : snoop_invalidate_request_seq
