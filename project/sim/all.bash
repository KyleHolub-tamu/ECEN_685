#!/bin/bash
#add passing test cases here
declare -a arr=(
	"read_miss_icache"
	"read_hit_icache"
	"write_miss_icache"
	"write_hit_icache"
	"lru_read_miss_icache"
	"read_miss_dcache_l2_service"
	"read_hit_dcache"
	"write_miss_dcache_l2_service"
	"write_hit_dcache"
	"read_miss_dcache_snoop_service"
	"simul_read_test"
	"simul_write_test"
	"lru_read_miss_dcache"
	"lru_write_miss_dcache"
	"snoop_read_request"
	"snoop_write_request"
	"snoop_invalidate_request"
	"rr_write_test"
	"random_test"
	"random_delay_test"
	"random_single_set_test"
	"random_six_address_test"
        )

if [! -d logs]; then
    mkdir logs
fi
source ../../setup.bash
./CLEAR_LOGS
./CLEAR
irun -f cmd_line_comp_elab.f

for i in "${arr[@]}"
do
    irun -f cmd_line.f +UVM_TESTNAME=$i -svseed 1 -covtest "$i"
    cp xrun.log irun.log
    mv irun.log logs/"$i".log
done
./CLEAR
