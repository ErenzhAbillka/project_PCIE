from pathlib import Path
import hashlib
import json

root = Path('E:/FPGA_Doc/project_PCIE')
backup = root/'adc_dsp_boundary_backup_20261004'
rel = Path('project_PCIE.srcs/sources_1/bd/xdma_pcie/xdma_pcie.bd')
before = json.loads((backup/rel).read_text())['design']
after = json.loads((root/rel).read_text())['design']
nets = after['nets']

def connected(*pins):
    assert any(set(pins).issubset(set(n['ports'])) for n in nets.values()), pins

def separated(*pins):
    assert not any(set(pins).issubset(set(n['ports'])) for n in nets.values()), pins

connected('top_layer_0/sys_clk', 'axis_data_fifo_0/s_axis_aclk')
connected('top_layer_0/adc_fifo_aresetn', 'axis_data_fifo_0/s_axis_aresetn')
connected('ddr4_0/c0_ddr4_ui_clk', 'axis_data_fifo_0/m_axis_aclk', 'wr_addr_0/clk')
for top, fifo in [('stream_data','s_axis_tdata'), ('stream_valid','s_axis_tvalid'), ('stream_ready','s_axis_tready')]:
    connected('top_layer_0/'+top, 'axis_data_fifo_0/'+fifo)
for fifo, writer in [('m_axis_tdata','i_data'), ('m_axis_tvalid','i_valid'), ('m_axis_tready','fifo_ready')]:
    separated('axis_data_fifo_0/'+fifo, 'wr_addr_0/'+writer)
connected('zero_1/dout','axis_data_fifo_0/m_axis_tready','wr_addr_0/i_valid','wr_addr_0/i_last')
connected('zero_32/dout','wr_addr_0/i_data')
connected('top_layer_0/acquisition_enable','vio_readback/probe_out1')
connected('top_layer_0/adc_overflow','vio_readback/probe_in4')
for parameter, value in {'FIFO_DEPTH':'4096','FIFO_MODE':'1','IS_ACLK_ASYNC':'1','HAS_TLAST':'0','TDATA_NUM_BYTES':'4'}.items():
    assert after['components']['axis_data_fifo_0']['parameters'][parameter]['value']==value, parameter
for cell in ['wr_addr_0','ddr4_0','xdma_0','axi_smc','rst_ddr','perst_invert','xdma_reset_invert']:
    assert before['components'][cell].get('parameters',{})==after['components'][cell].get('parameters',{}), cell
assert before['interface_nets']==after['interface_nets'], 'Backend AXI / DDR / PCIe interfaces changed'
assert before['addressing']==after['addressing'], 'Address map changed'
for rel in ['project_PCIE.srcs/sources_1/new/wr_addr.v', 'project_PCIE.srcs/sources_1/new/old_prj_src/adc_driver.v']:
    assert (root/rel).read_bytes()==(backup/rel).read_bytes(), rel
reference = Path('E:/Documents/ChatGPT/project_PCIE/fpga_compat_20261001/project_PCIE.srcs/sources_1/new/wr_addr.v')
current = root/'project_PCIE.srcs/sources_1/new/wr_addr.v'
assert current.read_bytes()==reference.read_bytes(), 'Writer differs from October 1 source'
print('PASS: source stops at asynchronous FIFO; wr_addr and backend parameters, interfaces and map unchanged')
print('wr_addr SHA256:', hashlib.sha256(current.read_bytes()).hexdigest())
