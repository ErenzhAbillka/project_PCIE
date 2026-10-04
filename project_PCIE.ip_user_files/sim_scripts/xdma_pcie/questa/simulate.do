onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib xdma_pcie_opt

do {wave.do}

view wave
view structure
view signals

do {xdma_pcie.udo}

run -all

quit -force
