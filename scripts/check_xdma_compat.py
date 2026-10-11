"""Check the isolated user BAR required by the installed legacy XDMA driver."""
import json
from pathlib import Path
import xml.etree.ElementTree as ET


def check_compat(root, design):
    params = design['components']['xdma_0']['parameters']
    for name, value in {
        'axilite_master_en': 'true',
        'axilite_master_scale': 'Kilobytes',
        'axilite_master_size': '32',
        'pf0_device_id': '8028',
        'pl_link_cap_max_link_speed': '5.0_GT/s',
        'pl_link_cap_max_link_width': 'X8',
        'axi_data_width': '256_bit',
        'axisten_freq': '125',
        'xdma_axi_intf_mm': 'AXI_Memory_Mapped',
        'xdma_axilite_slave': 'false',
    }.items():
        assert params[name]['value'] == value, ('XDMA', name)

    ctrl = design['components']['compat_bram_ctrl']
    bram = design['components']['compat_bram']
    assert ctrl['vlnv'] == 'xilinx.com:ip:axi_bram_ctrl:4.1'
    assert bram['vlnv'] == 'xilinx.com:ip:blk_mem_gen:8.4'
    for name, value in {'PROTOCOL': 'AXI4LITE', 'SINGLE_PORT_BRAM': '1', 'DATA_WIDTH': '32'}.items():
        assert ctrl['parameters'].get(name, {'value': '32'})['value'] == value, name
    assert bram['parameters']['Memory_Type']['value'] == 'Single_Port_RAM'

    for pins in [('xdma_0/M_AXI_LITE', 'compat_bram_ctrl/S_AXI'),
                 ('compat_bram_ctrl/BRAM_PORTA', 'compat_bram/BRAM_PORTA')]:
        assert any(set(net['interface_ports']) == set(pins)
                   for net in design['interface_nets'].values()), pins
    for pins in [('xdma_0/axi_aclk', 'compat_bram_ctrl/s_axi_aclk'),
                 ('xdma_0/axi_aresetn', 'compat_bram_ctrl/s_axi_aresetn'),
                 ('zero_1/dout', 'xdma_0/usr_irq_req')]:
        assert any(set(pins) <= set(net['ports']) for net in design['nets'].values()), pins
    lite = design['addressing']['/xdma_0']['address_spaces']['M_AXI_LITE']
    assert lite['range'] == '4G' and lite['width'] == '32'
    segments = list(lite['segments'].values())
    assert len(segments) == 1
    segment = segments[0]
    assert segment['range'] == '32K' and int(segment['offset'], 16) == 0
    assert segment['address_block'] == '/compat_bram_ctrl/S_AXI/Mem0'

    # Check generated hard-IP values as well as its GUI parameters.
    xci = root / 'project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/xdma_pcie_xdma_0_0_pcie3_ip.xci'
    values = {}
    for element in ET.parse(xci).iter():
        ref = next((v for k, v in element.attrib.items() if k.endswith('referenceId')), '')
        if element.text and ref.startswith(('PARAM_VALUE.', 'MODELPARAM_VALUE.')):
            values[ref] = element.text.strip()
    for index, size, aperture in [(0, '32', '0x08'), (1, '64', '0x09')]:
        for suffix, value in {'enabled': 'true', 'scale': 'Kilobytes', 'size': size,
                              '64bit': 'false', 'prefetchable': 'false', 'type': 'Memory'}.items():
            key = f'PARAM_VALUE.pf0_bar{index}_{suffix}'
            assert values[key] == value, key
        assert values[f'MODELPARAM_VALUE.PF0_BAR{index}_APERTURE_SIZE'] == aperture
        assert values[f'MODELPARAM_VALUE.PF0_BAR{index}_CONTROL'] == '0x4'
    for index in range(2, 6):
        assert values[f'PARAM_VALUE.pf0_bar{index}_enabled'] == 'false'
        assert values[f'MODELPARAM_VALUE.PF0_BAR{index}_APERTURE_SIZE'] == '0x00'
        assert values[f'MODELPARAM_VALUE.PF0_BAR{index}_CONTROL'] == '0x0'
    for name, value in {'PARAM_VALUE.PF0_DEVICE_ID': '8028',
                        'PARAM_VALUE.PL_LINK_CAP_MAX_LINK_SPEED': '5.0_GT/s',
                        'PARAM_VALUE.PL_LINK_CAP_MAX_LINK_WIDTH': 'X8',
                        'MODELPARAM_VALUE.PF0_DEVICE_ID': '0x8028',
                        'MODELPARAM_VALUE.PL_LINK_CAP_MAX_LINK_SPEED': '2',
                        'MODELPARAM_VALUE.PL_LINK_CAP_MAX_LINK_WIDTH': '8'}.items():
        assert values[name] == value, name
    print('XDMA_COMPAT_CHECK_PASS: 8028 Gen2x8; BAR0 user 32 KiB, BAR1 control 64 KiB; 32-bit nonprefetch; BAR2-5 disabled; isolated XDMA-clocked BRAM')


if __name__ == '__main__':
    root = Path(__file__).resolve().parents[1]
    design = json.loads((root / 'project_PCIE.srcs/sources_1/bd/xdma_pcie/xdma_pcie.bd').read_text())['design']
    check_compat(root, design)
