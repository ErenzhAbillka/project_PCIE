onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+xdma_pcie -L xil_defaultlib -L xpm -L microblaze_v11_0_0 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_13 -L lmb_v10_v3_0_9 -L lmb_bram_if_cntlr_v4_0_15 -L blk_mem_gen_v8_4_2 -L iomodule_v3_1_4 -L gtwizard_ultrascale_v1_7_5 -L xdma_v4_1_2 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.xdma_pcie xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {xdma_pcie.udo}

run -all

endsim

quit -force
