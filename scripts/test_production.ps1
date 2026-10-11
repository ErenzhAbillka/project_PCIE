$ErrorActionPreference='Stop'
$stage=Split-Path $PSScriptRoot -Parent
$bin='D:\Xilinxx\Vivado\2018.3\bin'
$out=Join-Path $stage 'link_bulid\ADC_RAW_TX\production_sim'
New-Item -ItemType Directory -Path $out -Force | Out-Null
Push-Location $out
try {
 & "$bin\xvlog.bat" --sv "$stage\project_PCIE.srcs\sources_1\new\das_processing\das_trace_process.v" "$stage\project_PCIE.srcs\sim_1\PCIEv2_0\tb_production_frame.sv"
 if($LASTEXITCODE-ne 0) {throw 'Production test compilation failed'}
 & "$bin\xelab.bat" tb_production_frame -s production_test
 if($LASTEXITCODE-ne 0) {throw 'Production test elaboration failed'}
 & "$bin\xsim.bat" production_test -runall
 $log=Get-Content -LiteralPath xsim.log -Raw
 if($log -match 'Fatal:|ERROR:' -or $log -notmatch 'DAS_PRODUCTION_FRAME_PASS') {throw 'Production test failed'}
} finally {Pop-Location}
