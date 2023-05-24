//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_seqs_c.sv
// Description: cpu sequences for a single core cpu component
// Designers: Venky & Suru
//=====================================================================

class cpu_base_seq extends uvm_sequence #(cpu_transaction_c);

    `uvm_object_utils(cpu_base_seq)

    function new (string name = "cpu_base_seq");
        super.new(name);
    endfunction

    task pre_body();
        if(starting_phase != null) begin
            starting_phase.raise_objection(this, get_type_name());
            `uvm_info(get_type_name(), "raise_objection", UVM_LOW)
        end
    endtask : pre_body

    task post_body();
        if(starting_phase != null) begin
            starting_phase.drop_objection(this, get_type_name());
            `uvm_info(get_type_name(), "drop_objection", UVM_LOW)
        end
    endtask : post_body

endclass : cpu_base_seq

class simple_seq extends uvm_sequence #(cpu_transaction_c);

    `uvm_object_utils(simple_seq)

    function new (string name = "simple_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "executing 5 cpu transaction", UVM_LOW)
        repeat(5)
            `uvm_do_with(req, {request_type == READ_REQ;})
    endtask
endclass : simple_seq

class hundred_random_seq extends uvm_sequence #(cpu_transaction_c);

    `uvm_object_utils(hundred_random_seq)
    rand bit[13:0] index[10];
    int dcache_acc, index_choice, wr, wait_time;
    rand int unsigned wait_time_max;
    rand int unsigned index_choice_max;

    constraint ct_initial{
        soft wait_time_max == 50;
        soft index_choice_max == 2;
        index_choice_max <= 10;
    }

    function new (string name = "hundred_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Hundred Random CPU Transactions", UVM_LOW)
        repeat(100) begin
            dcache_acc = $urandom_range(1);
            index_choice = $urandom_range(index_choice_max-1);
            wr = $urandom_range(1);
            wait_time = $urandom_range(wait_time_max);
            //`uvm_info(get_type_name(), $sformatf("hundred_random_seq: index[0] = %0h, index[1] = %0h, wait_time = %0d",index[0],index[1],wait_time), UVM_LOW)
            if(dcache_acc) begin
                `uvm_do_with(req, {access_cache_type == DCACHE_ACC; request_type == wr; address[15:2] == index[index_choice]; wait_cycles == wait_time;})
            end else begin
                `uvm_do_with(req, {access_cache_type == ICACHE_ACC; request_type == wr; address[15:2] == index[index_choice]; wait_cycles == wait_time;})
            end
        end
    endtask
endclass : hundred_random_seq

class six_addr_random_seq extends uvm_sequence #(cpu_transaction_c);

    `uvm_object_utils(six_addr_random_seq)
    rand bit[29:0] six_addr[6];
    int addr_choice, wr, wait_time;
    rand int unsigned wait_time_max;

    constraint ct_initial{
        soft wait_time_max == 50;
    }

    function new (string name = "six_addr_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Six Address Hundred Random CPU Transactions", UVM_LOW)
        repeat(20) begin
            addr_choice = $urandom_range(5);
            wr = $urandom_range(1);
            wait_time = $urandom_range(wait_time_max);
            //`uvm_info(get_type_name(), $sformatf("six_addr_random_seq: index[0] = %0h, index[1] = %0h, wait_time = %0d",index[0],index[1],wait_time), UVM_LOW)
            `uvm_do_with(req, {request_type == wr; address[31:2] == six_addr[addr_choice]; wait_cycles == wait_time;})
        end
    endtask
endclass : six_addr_random_seq
