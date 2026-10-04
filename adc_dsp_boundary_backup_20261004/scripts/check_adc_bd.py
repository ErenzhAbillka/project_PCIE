import json
from pathlib import Path

root = Path('E:/FPGA_Doc/project_PCIE')
design = json.loads((root/'project_PCIE.srcs/sources_1/bd/xdma_pcie/xdma_pcie.bd').read_text())['design']
nets = design['nets']

def connected(*pins):
    assert any(set(pins).issubset(set(net['ports'])) for net in nets.values()), pins

connected('ddr4_0/c0_ddr4_ui_clk', 'top_layer_0/ctrl_clk', 'wr_addr_0/clk')
connected('rst_ddr/peripheral_aresetn', 'top_layer_0/rst_n')
for a, b in [('stream_data', 's_axis_tdata'), ('stream_valid', 's_axis_tvalid'), ('stream_last', 's_axis_tlast'), ('stream_ready', 's_axis_tready')]:
    connected('top_layer_0/'+a, 'axis_data_fifo_0/'+b)
connected('wr_addr_0/m00_axi_txn_done', 'top_layer_0/write_burst_done')
connected('vio_readback/probe_out1', 'top_layer_0/capture_toggle')
for pin in ['device_spi_sda', 'device_spi_sclk', 'adk_spi_csb', 'adc_spi_csb', 'dac_spi_csb', 'adc_sync']:
    connected(pin, 'top_layer_0/'+pin)
for net in nets.values():
    assert 'wr_addr_0/m00_axi_wready' not in net['ports'], 'Scalar net overrides AXI WREADY interface'
assert 'AXI_data_out_0_0' not in design['components']
assert design['ports']['data_pin_p_0']['left'] == '13'
assert design['ports']['data_pin_n_0']['left'] == '13'
print('PASS: ADC source, 14-bit pins, SPI, control/reset, AXIS, VIO and AXI handshake wiring')
