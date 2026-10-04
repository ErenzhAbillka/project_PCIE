"""Check the saved PCIe/DDR4 BD and board pin constraints (no Vivado needed)."""
import json
import re
import sys
from pathlib import Path

bd, xdc = map(Path, sys.argv[1:])
d = json.loads(bd.read_text())['design']

def connected(group, key, *pins):
    assert any(set(pins) <= set(net[key]) for net in d[group].values()), pins

for pair in [('xdma_0/M_AXI', 'axi_smc/S00_AXI'),
             ('wr_addr_0/m00_axi', 'axi_smc/S01_AXI'),
             ('axi_smc/M00_AXI', 'ddr4_0/C0_DDR4_S_AXI')]:
    connected('interface_nets', 'interface_ports', *pair)
connected('nets', 'ports', 'ddr4_0/c0_ddr4_ui_clk', 'wr_addr_0/clk',
          'wr_addr_0/m00_axi_aclk', 'axis_data_fifo_0/s_axis_aclk',
          'AXI_data_out_0_0/clk', 'axi_smc/aclk')
connected('nets', 'ports', 'xdma_0/axi_aclk', 'axi_smc/aclk1')
connected('nets', 'ports', 'rst_ddr/peripheral_aresetn',
          'ddr4_0/c0_ddr4_aresetn', 'wr_addr_0/rst_n',
          'wr_addr_0/m00_axi_aresetn', 'axi_smc/aresetn')
connected('nets', 'ports', 'perst_invert/Res', 'ddr4_0/sys_rst')
connected('nets', 'ports', 'xdma_reset_invert/Res', 'rst_ddr/aux_reset_in')
connected('nets', 'ports', 'ddr4_0/c0_init_calib_complete', 'rst_ddr/dcm_locked')
for suffix, pin in [('tdata', 'i_data'), ('tlast', 'i_last'),
                    ('tvalid', 'i_valid'), ('tready', 'fifo_ready')]:
    connected('nets', 'ports', 'axis_data_fifo_0/m_axis_' + suffix, 'wr_addr_0/' + pin)
assert 'C0_DDR4_S_AXI_0' not in d['interface_ports']
assert set(d['ports']) == {'reset_rtl_0'}
for name, space in [('xdma_0', 'M_AXI'), ('wr_addr_0', 'm00_axi')]:
    segs = d['addressing']['/' + name]['address_spaces'][space]['segments']
    assert len(segs) == 1
    seg = next(iter(segs.values()))
    assert int(seg['offset'], 16) == 0 and seg['range'] == '4G'
p = d['components']['xdma_0']['parameters']
assert d['components']['ila_readback']['parameters']['C_MONITOR_TYPE']['value'] == 'Native'
assert d['components']['ila_readback']['parameters']['C_NUM_OF_PROBES']['value'] == '5'
for i, pin in enumerate(['o_data', 'o_valid', 'o_last', 'm00_axi_error', 'm00_axi_txn_done']):
    connected('nets', 'ports', 'wr_addr_0/' + pin, 'ila_readback/probe' + str(i))
assert p['pcie_blk_locn']['value'] == 'X0Y1'
assert p['select_quad']['value'] == 'GTH_Quad_227'
assert p['pl_link_cap_max_link_width']['value'] == 'X8'
assert p['pl_link_cap_max_link_speed']['value'] == '5.0_GT/s'
assert p['axi_data_width']['value'] == '256_bit'
assert p['axisten_freq']['value'] == '125'
text = xdc.read_text()
for stem, pins in [('rxp', 'F2 H2 K2 M2 P2 T2 V2 Y2'),
                   ('rxn', 'F1 H1 K1 M1 P1 T1 V1 Y1'),
                   ('txp', 'G4 J4 L4 N4 R4 U4 W4 AA4'),
                   ('txn', 'G3 J3 L3 N3 R3 U3 W3 AA3')]:
    for i, pin in enumerate(pins.split()):
        assert f'PACKAGE_PIN {pin} [get_ports {{pcie_7x_mgt_rtl_0_{stem}[{i}]}}]' in text
pins = re.findall(r'PACKAGE_PIN\s+(\w+)', text)
assert len(pins) == 152 and len(set(pins)) == 152, 'Missing or duplicate physical pins'
print('PASS: DDR4 paths, clocks, resets, FIFO handshake, 4 GiB maps, GT selection, 152 unique pins')
