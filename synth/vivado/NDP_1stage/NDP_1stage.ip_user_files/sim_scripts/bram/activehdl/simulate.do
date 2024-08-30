transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+bram  -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_6 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.bram xil_defaultlib.glbl

do {bram.udo}

run

endsim

quit -force
