//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_miss_dcache_l2_service.sv
// Description: Test for write-miss to D-cache -> serviced by L2
// Designers: Venky & Suru
//=====================================================================
typedef enum {SNOOP_IN_I_WMDL2 = 0, SNOOP_IN_E_WMDL2 = 1, SNOOP_IN_M_WMDL2 = 2, SNOOP_IN_S_WMDL2 = 3} case_wmdl2_t;

class write_miss_dcache_l2_service extends base_test;

    //component macro
    `uvm_component_utils(write_miss_dcache_l2_service)

    case_wmdl2_t case_wmdl2_type;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_miss_dcache_l2_service_seq::type_id::get());
        if(clp.get_arg_value("+SNOOP_IN=", temp_string))begin
            case_wmdl2_type = temp_string.atoi();
        end else if (!std::randomize(case_wmdl2_type)) `uvm_error(get_type_name(), "Randomize error on case_wmdl2_type");
        uvm_config_db#(case_wmdl2_t)::set(this,"tb.vsequencer.write_miss_dcache_l2_service_seq","case_wmdl2_type",case_wmdl2_type);
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_miss_dcache_l2_service test" , UVM_LOW)
    endtask: run_phase

endclass : write_miss_dcache_l2_service


// Sequence for a write-miss to D-cache -> serviced by L2
class write_miss_dcache_l2_service_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_miss_dcache_l2_service_seq)

    cpu_transaction_c trans;
    rand case_wmdl2_t case_wmdl2_type;
    rand bit [`ADDR_WID_LV1-1 : 0]  access_address;

    //constructor
    function new (string name="write_miss_dcache_l2_service_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        uvm_config_db#(case_wmdl2_t)::get(null,get_full_name(),"case_wmdl2_type", case_wmdl2_type);
        `uvm_info(get_type_name(), $sformatf("Case to run is %s",case_wmdl2_type.name()), UVM_LOW)

        // randomize the access_address with constraints for D-cache access
        if (!(std::randomize(access_address) with {access_address > `IL_DL_ADDR_BOUND;})) `uvm_error(get_type_name(), "Randomize error on access_address");

        // setup the snoop for the initial state (do nothing for SNOOP_IN_I_WMDL2)
        if (case_wmdl2_type == SNOOP_IN_E_WMDL2)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        else if (case_wmdl2_type == SNOOP_IN_M_WMDL2)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
        else if (case_wmdl2_type == SNOOP_IN_S_WMDL2)
        begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
            // evict the block from core0 by performing 4 random access to blocks mapping to the same set
            repeat(4) begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {access_cache_type == DCACHE_ACC; address[`INDEX_MSB_LV1:`INDEX_LSB_LV1] == access_address[`INDEX_MSB_LV1:`INDEX_LSB_LV1]; address != access_address;})
            end
        end

        // initiate a write request to the same access_address on core 0
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

        // read back to ensure data integrity
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

    endtask

endclass : write_miss_dcache_l2_service_seq
