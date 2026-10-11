from pathlib import Path
import json, hashlib, re
from copy import deepcopy
from check_xdma_compat import check_compat

root=Path(__file__).resolve().parents[1]
backup=root/'archive'/'backups'/'das_template_backup_20261004'
rel='project_PCIE.srcs/sources_1/bd/xdma_pcie/xdma_pcie.bd'
before=json.loads((backup/rel).read_text())['design']
after=json.loads((root/rel).read_text())['design']
def wired(design,*pins):
    assert any(set(pins).issubset(n['ports']) for n in design['nets'].values()),pins
for key in ['data','user','valid']:
    wired(after,'axis_data_fifo_0/m_axis_t'+key,'acquisition_router_0/adc_'+key)
    wired(after,'acquisition_router_0/das_adc_'+key,'das_processing/adc_'+key)
wired(after,'axis_data_fifo_0/m_axis_tready','acquisition_router_0/adc_ready')
wired(after,'das_processing/adc_ready','acquisition_router_0/das_adc_ready')
for key in ['data','valid','last']:
    wired(after,'das_processing/frame_'+key,'acquisition_router_0/das_frame_'+key)
    wired(after,'acquisition_router_0/frame_'+key,'das_writer_packet_0/frame_'+key)
wired(after,'das_processing/frame_ready','acquisition_router_0/das_frame_ready')
wired(after,'acquisition_router_0/frame_ready','das_writer_packet_0/frame_ready')
for key in ['data','valid','last']:
    wired(after,'das_writer_packet_0/writer_'+key,'wr_addr_0/i_'+key)
wired(after,'wr_addr_0/fifo_ready','das_writer_packet_0/writer_ready')
wired(after,'top_layer_0/stream_user','axis_data_fifo_0/s_axis_tuser')
for pin in ['wr_addr_0/i_data','wr_addr_0/i_valid','wr_addr_0/i_last','axis_data_fifo_0/m_axis_tready']:
    assert not any(pin in n['ports'] and any(p.startswith('zero_') for p in n['ports']) for n in after['nets'].values()),pin
for key,net in before['interface_nets'].items():
    assert after['interface_nets'][key]==net,('Backend interface changed',key)
check_compat(root,after)
# Only the isolated user BAR may extend the original DDR/PCIe backend.
addressing=deepcopy(after['addressing'])
del addressing['/xdma_0']['address_spaces']['M_AXI_LITE']
assert before['addressing']==addressing,'Original backend addressing changed'
compat_params={'axilite_master_en','axilite_master_scale','axilite_master_size'}
before_xdma=before['components']['xdma_0']['parameters']
after_xdma=after['components']['xdma_0']['parameters']
assert before_xdma['axilite_master_en']['value']=='false'
assert {k:v for k,v in before_xdma.items() if k not in compat_params}=={
    k:v for k,v in after_xdma.items() if k not in compat_params
},'Unexpected XDMA parameter change'
for c in ['ddr4_0','axi_smc','rst_ddr','perst_invert','xdma_reset_invert']:
    assert before['components'][c].get('parameters',{})==after['components'][c].get('parameters',{}),c
for param in ['WRITE_BASE_ADDR','WRITE_WINDOW_BYTES']:
    assert int(after['components']['wr_addr_0']['parameters'][param]['value'],0)==0x100000
dsp=after['components']['das_processing']
assert set(dsp['components'])==set(['phase_source_0','dds_compiler_0','mult_iq_0','fir_compiler_i','fir_compiler_q','iq_align_0','cordic_amp_phase_0','dif_acc_phase_0'])
for leg in ['i','q']:
    for sig in ['data','user','valid','ready']:
        wired(dsp,'mult_iq_0/'+leg+'_'+sig,'fir_compiler_'+leg+'/s_axis_data_t'+sig)
        wired(dsp,'fir_compiler_'+leg+'/m_axis_data_t'+sig,'iq_align_0/'+leg+'_'+sig)
for index,pin in {
    11:'top_layer_0/adc_test_active',12:'top_layer_0/adc_test_error',
    13:'top_layer_0/adc_test_checked_count',14:'top_layer_0/adc_test_error_count',
    15:'top_layer_0/adc_test_config_locked',16:'acquisition_router_0/raw_capture_complete',
    17:'acquisition_router_0/raw_capture_error',18:'acquisition_router_0/raw_frame_sent',
    19:'acquisition_router_0/configuration_error',20:'acquisition_router_0/raw_mode_active',
    24:'acquisition_router_0/mode_locked',
}.items():
    wired(after,pin,'vio_readback/probe_in'+str(index))
wired(after,'vio_readback/probe_out0','wr_addr_0/xdma_valid')
wired(after,'vio_readback/probe_out1','acquisition_router_0/start')
wired(after,'vio_readback/probe_out2','das_processing/phase_start')
wired(after,'acquisition_router_0/frontend_enable','top_layer_0/acquisition_enable')
wired(after,'acquisition_router_0/adc_test_request','top_layer_0/adc_test_enable')
wired(after,'top_layer_0/adc_test_active','acquisition_router_0/adc_test_active')
wired(after,'top_layer_0/adc_overflow','acquisition_router_0/input_fault','das_processing/input_fault')
for index,pin in {3:'raw_mode_cfg',4:'test_enable_cfg',5:'epoch_cfg',6:'config_id_cfg',7:'tx_enable_cfg'}.items():
    wired(after,'vio_readback/probe_out'+str(index),'acquisition_router_0/'+pin)
for index,pin in {0:'data',1:'valid',2:'ready',3:'last'}.items():
    wired(after,'acquisition_router_0/frame_'+pin,'ila_das/probe'+str(index))
vio=after['components']['vio_readback']['parameters']
assert int(vio['C_NUM_PROBE_OUT']['value'])==9
assert int(vio['C_NUM_PROBE_IN']['value'])==25
for index in range(9):
    assert int(vio.get('C_PROBE_OUT'+str(index)+'_INIT_VAL',{'value':'0'})['value'],0)==0
for index in (5,6):
    assert int(vio['C_PROBE_OUT'+str(index)+'_WIDTH']['value'])==32
wired(after,'acquisition_router_0/tx_enable_locked','top_layer_0/tx_enable')
wired(after,'vio_readback/probe_out8','top_layer_0/tx_abort')
for index,signal in {21:'tx_init_done',22:'tx_fault'}.items():
    wired(after,'top_layer_0/'+signal,'acquisition_router_0/'+signal,'vio_readback/probe_in'+str(index))
wired(after,'top_layer_0/tx_status','vio_readback/probe_in23')
# Input widths are inferred from connected nets and omitted from BD JSON.
vio_hdl=(root/'project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_vio_readback_0/synth/xdma_pcie_vio_readback_0.v').read_text()
assert re.search(r'input\s*\[31\s*:\s*0\]\s*probe_in23\s*;',vio_hdl)
for signal in ('dac_data_p','dac_data_n','dac_dci_p','dac_dci_n','dac_frame_p','dac_frame_n'):
    wired(after,'top_layer_0/'+signal,signal)
tx_rom=root/'project_PCIE.srcs/sources_1/new/tgd_tx/sine_4096.mem'
assert tx_rom.is_file()
configured_rom=Path(after['components']['top_layer_0']['parameters']['TX_SINE_MEM']['value'])
if configured_rom == Path('sine_4096.mem'): configured_rom=tx_rom
elif not configured_rom.is_absolute(): configured_rom=root/configured_rom
assert tx_rom.resolve()==configured_rom.resolve(),'TX_SINE_MEM must resolve to this project ROM; refresh with scripts/build_das.tcl after moving the project'
router=after['components']['acquisition_router_0']['parameters']
for key,value in {'TRACE_POINTS':16320,'FRAME_WORDS':16384,'SAMPLE_RATE':125000000,'TRACE_PERIOD':31250}.items():
    assert int(router.get(key,{'value':str(value)})['value'])==value,key
# ADC capture datapath may add a separate MMCM output for coherent DAC clock.
# Preserve the original ADC input primitive chain, lane mapping and timing.
driver=(root/'project_PCIE.srcs/sources_1/new/old_prj_src/adc_driver.v').read_text()
driver=re.sub(r'//[^\n]*','',driver)
driver_compact=re.sub(r'\s+','',driver)
for token in ['MMCME3_ADV#(','.CLKIN1_PERIOD(8.000)', '.DIVCLK_DIVIDE(1)',
              '.CLKFBOUT_MULT_F(8.000)', '.CLKOUT0_DIVIDE_F(8.000)',
              '.CLKOUT0_PHASE(SAMPLE_PHASE_DEG)', 'bit_index<14', 'IBUFDS#(',
              'IDELAYE3#(', '.DELAY_FORMAT("COUNT")', '.DELAY_TYPE("FIXED")',
              '.DELAY_VALUE(INPUT_DELAY_TAPS)', '.EN_VTC(1\'b0)', 'IDDRE1#(',
              '.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")', '.IS_CB_INVERTED(1\'b1)',
              '.Q1(adc_data_out_ch1[bit_index])', '.Q2(adc_data_out_ch2[bit_index])',
              '.C(adc_data_clk_bufg)', '.CB(adc_data_clk_bufg)', '.D(data_delayed[bit_index])']:
    assert token in driver_compact,('ADC input primitive contract',token)
# The 2026-10-10 continuity monitor adds exactly two single-bit CDC exceptions.
# Preserve every original ADC package pin, I/O standard and timing constraint.
xdc='project_PCIE.srcs/constrs_1/new/fmc_adc_pins.xdc'
monitor_constraint = (
    '# ADC continuity monitor: cut only the two independent single-bit CDC inputs.\n'
    'set adc_monitor_sync [get_pins -hier -regexp {.*capture_monitor_inst/(heartbeat_sync_reg|sample_valid_sync_reg)\\[0\\]/D}]\n'
    'set_false_path -to $adc_monitor_sync\n'
)
current_xdc=(root/xdc).read_text(encoding='utf-8')
assert current_xdc.count(monitor_constraint)==1,'Missing or altered ADC monitor CDC constraints'
diagnostic_constraint = (
    '# ADC diagnostic controls/handshake: cut only the three first-stage D inputs.\n'
    'set adc_diagnostic_sync [get_pins -hier -regexp {.*(ramp_checker_inst/enable_sync_reg|test_snapshot_inst/request_sync_reg|test_snapshot_inst/ack_sync_reg)\\[0\\]/D}]\n'
    'set_false_path -to $adc_diagnostic_sync\n'
    '# Held snapshot bundle is stable through the synchronized acknowledgement.\n'
    '# Earliest destination capture is >=15 ns after source hold; budget 10 ns.\n'
    'set adc_snapshot_source [get_pins -hier -regexp {.*test_snapshot_inst/snapshot_data_reg\\[[0-9]+\\]/C}]\n'
    'set adc_snapshot_target [get_pins -hier -regexp {.*test_snapshot_inst/(error_reg|error_count_reg\\[[0-9]+\\]|checked_count_reg\\[[0-9]+\\])/D}]\n'
    'set_max_delay -datapath_only 10.000 -from $adc_snapshot_source -to $adc_snapshot_target\n'
)
assert current_xdc.count(diagnostic_constraint)==1,'Missing or altered ADC diagnostic CDC constraints'
reset_before='(adc_driver_inst/(reset_sync_reg|valid_sync_reg)|fifo_reset_sync_reg)'
reset_after='(adc_driver_inst/(reset_sync_reg|valid_sync_reg)|fifo_reset_sync_reg|checker_reset_sync_reg)'
assert current_xdc.count(reset_after)==1,'Missing precise checker reset-release exception'
original_xdc=current_xdc.replace(monitor_constraint,'').replace(diagnostic_constraint,'').replace(reset_after,reset_before)
assert original_xdc==(backup/xdc).read_text(encoding='utf-8'),'Unexpected ADC pin/timing constraint changes'
writer='project_PCIE.srcs/sources_1/new/wr_addr.v'
expected=(backup/writer).read_bytes()
expected=expected.replace(b'parameter integer C_M00_AXI_DATA_WIDTH\t= 32',b'parameter integer C_M00_AXI_DATA_WIDTH\t= 32,\r\n        parameter [31:0] WRITE_BASE_ADDR = 32\'h00000000,\r\n        parameter [31:0] WRITE_WINDOW_BYTES = 32\'h00001000')
expected=expected.replace(b'// Fixed 32-bit AXI master: four beats per packet, 4 KiB write window.',b'// Fixed 32-bit AXI master: four beats per packet; parameterized write ring.')
expected=expected.replace(b'aw_addr <= 0;',b'aw_addr <= WRITE_BASE_ADDR;')
expected=expected.replace(b"aw_addr <= (aw_addr == 32'h00000ff0) ? 0 : aw_addr + 32'd16;",b"aw_addr <= (aw_addr >= WRITE_BASE_ADDR + WRITE_WINDOW_BYTES - 32'd16) ? WRITE_BASE_ADDR : aw_addr + 32'd16;")
# 2026-10-10: writer now fail-stops on malformed packets / bad BRESP.
# Keep its original external contract; RTL fault-injection tests check behavior.
actual=(root/writer).read_text(encoding='utf-8')
expected_text=expected.decode().replace('\r\n','\n')
def module_header(text):
    return re.sub(r'\s+','',text[text.index('module wr_addr'):text.index(');')+2])
assert module_header(actual)==module_header(expected_text),'Writer ports or parameters changed'
assert "aw_addr <= WRITE_BASE_ADDR;" in actual
assert "WRITE_BASE_ADDR + WRITE_WINDOW_BYTES - 32'd16" in actual
print('DAS_BD_CHECK_PASS: RAW/DAS router and diagnostic VIO connected; ADC primitives/pins/timing and writer interface/ring preserved; DDR/PCIe backend retained')
print('Writer fault behavior: run scripts/run_acquisition_rtl_check.ps1 -Phase Writer')
print('BD SHA256:',hashlib.sha256((root/rel).read_bytes()).hexdigest())
