//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_lib.svh
// Description: Base test class and list of tests
// Designers: Venky & Suru
//=====================================================================

`include "base_test.sv"
`include "read_miss_icache.sv"
`include "read_hit_icache.sv"
`include "write_miss_icache.sv"
`include "write_hit_icache.sv"
`include "read_miss_dcache_l2_service.sv"
`include "read_miss_dcache_snoop_service.sv"
`include "read_hit_dcache.sv"
`include "write_miss_dcache_l2_service.sv"
`include "write_hit_dcache.sv"
`include "lru_read_miss_icache.sv"
`include "lru_read_miss_dcache.sv"
`include "lru_write_miss_dcache.sv"
`include "snoop_read_request.sv"
`include "snoop_write_request.sv"
`include "snoop_invalidate_request.sv"
`include "random_test.sv"
`include "simul_read_test.sv"
`include "simul_write_test.sv"
`include "rr_write_test.sv"
`include "random_single_set_test.sv"
`include "random_delay_test.sv"
`include "random_six_address_test.sv"
