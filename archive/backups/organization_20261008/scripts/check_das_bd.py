from pathlib import Path
import json, hashlib

root=Path('E:/FPGA_Doc/project_PCIE')
backup=root/'das_template_backup_20261004'
rel='project_PCIE.srcs/sources_1/bd/xdma_pcie/xdma_pcie.bd'
before=json.loads((backup/rel).read_text())['design']
after=json.loads((root/rel).read_text())['design']
def wired(design,*pins):
    assert any(set(pins).issubset(n['ports']) for n in design['nets'].values()),pins
for key in ['data','valid','ready']:
    wired(after,'axis_data_fifo_0/m_axis_t'+key,'das_processing/adc_'+key)
for key in ['data','valid','last']:
    wired(after,'das_writer_packet_0/writer_'+key,'wr_addr_0/i_'+key)
wired(after,'wr_addr_0/fifo_ready','das_writer_packet_0/writer_ready')
wired(after,'top_layer_0/stream_user','axis_data_fifo_0/s_axis_tuser')
wired(after,'axis_data_fifo_0/m_axis_tuser','das_processing/adc_user')
for pin in ['wr_addr_0/i_data','wr_addr_0/i_valid','wr_addr_0/i_last','axis_data_fifo_0/m_axis_tready']:
    assert not any(pin in n['ports'] and any(p.startswith('zero_') for p in n['ports']) for n in after['nets'].values()),pin
assert before['interface_nets']==after['interface_nets']
assert before['addressing']==after['addressing']
for c in ['ddr4_0','xdma_0','axi_smc','rst_ddr','perst_invert','xdma_reset_invert']:
    assert before['components'][c].get('parameters',{})==after['components'][c].get('parameters',{}),c
for param in ['WRITE_BASE_ADDR','WRITE_WINDOW_BYTES']:
    assert int(after['components']['wr_addr_0']['parameters'][param]['value'],0)==0x100000
dsp=after['components']['das_processing']
assert set(dsp['components'])==set(['phase_source_0','dds_compiler_0','mult_iq_0','fir_compiler_i','fir_compiler_q','iq_align_0','cordic_amp_phase_0','dif_acc_phase_0'])
for leg in ['i','q']:
    for sig in ['data','user','valid','ready']:
        wired(dsp,'mult_iq_0/'+leg+'_'+sig,'fir_compiler_'+leg+'/s_axis_data_t'+sig)
        wired(dsp,'fir_compiler_'+leg+'/m_axis_data_t'+sig,'iq_align_0/'+leg+'_'+sig)
for p in ['project_PCIE.srcs/sources_1/new/old_prj_src/adc_driver.v','project_PCIE.srcs/constrs_1/new/fmc_adc_pins.xdc']:
    assert (backup/p).read_bytes()==(root/p).read_bytes(),p
writer='project_PCIE.srcs/sources_1/new/wr_addr.v'
expected=(backup/writer).read_bytes()
expected=expected.replace(b'parameter integer C_M00_AXI_DATA_WIDTH\t= 32',b'parameter integer C_M00_AXI_DATA_WIDTH\t= 32,\r\n        parameter [31:0] WRITE_BASE_ADDR = 32\'h00000000,\r\n        parameter [31:0] WRITE_WINDOW_BYTES = 32\'h00001000')
expected=expected.replace(b'// Fixed 32-bit AXI master: four beats per packet, 4 KiB write window.',b'// Fixed 32-bit AXI master: four beats per packet; parameterized write ring.')
expected=expected.replace(b'aw_addr <= 0;',b'aw_addr <= WRITE_BASE_ADDR;')
expected=expected.replace(b"aw_addr <= (aw_addr == 32'h00000ff0) ? 0 : aw_addr + 32'd16;",b"aw_addr <= (aw_addr >= WRITE_BASE_ADDR + WRITE_WINDOW_BYTES - 32'd16) ? WRITE_BASE_ADDR : aw_addr + 32'd16;")
assert (root/writer).read_bytes()==expected,'Unexpected writer changes beyond address parameterization'
print('DAS_BD_CHECK_PASS: processing connected; writer only address window changed; DDR/PCIe backend retained')
print('BD SHA256:',hashlib.sha256((root/rel).read_bytes()).hexdigest())
