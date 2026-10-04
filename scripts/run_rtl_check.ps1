param([string]$VivadoBin = 'D:\Xilinxx\Vivado\2018.3\bin')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$sources = Join-Path $projectRoot 'project_PCIE.srcs\sources_1\new'
$simDir = Join-Path $PSScriptRoot 'rtl_check_output'
New-Item -ItemType Directory -Path $simDir -Force | Out-Null
Push-Location $simDir
try {
    & (Join-Path $VivadoBin 'xvlog.bat') --sv (Join-Path $sources 'AXI_data_out_0.v') (Join-Path $sources 'wr_addr.v') (Join-Path $PSScriptRoot 'tb_wr_addr.sv')
    if ($LASTEXITCODE -ne 0) { throw 'RTL compilation failed' }
    & (Join-Path $VivadoBin 'xelab.bat') tb_wr_addr -s link_rtl_test -timescale 1ns/1ps
    if ($LASTEXITCODE -ne 0) { throw 'RTL elaboration failed' }
    & (Join-Path $VivadoBin 'xsim.bat') link_rtl_test -runall
    if ($LASTEXITCODE -ne 0) { throw 'RTL simulation failed' }
    $log = Get-Content -LiteralPath 'xsim.log' -Raw
    if ($log -notmatch 'PASS: 1024 LFSR words' -or $log -notmatch 'PASS: read AR stall' -or $log -match 'Fatal:') { throw 'Simulation assertions did not pass' }
} finally { Pop-Location }
