param(
    [string]$VivadoBin = 'D:\Xilinxx\Vivado\2018.3\bin',
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$OutputDir,
    [ValidateSet('All', 'Writer', 'Raw', 'Adc', 'Dac')]
    [string]$Phase = 'All'
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
if (!$OutputDir) {
    $OutputDir = Join-Path ([IO.Path]::GetTempPath()) ('pcie_acquisition_rtl_' + [guid]::NewGuid().ToString('N'))
}
$OutputDir = [IO.Path]::GetFullPath($OutputDir)
if ($OutputDir.TrimEnd('\', '/') -eq $ProjectRoot.TrimEnd('\', '/') -or
    $OutputDir.StartsWith($ProjectRoot.TrimEnd('\', '/') + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDir must be outside ProjectRoot so simulation never changes project files.'
}
$sources = Join-Path $ProjectRoot 'project_PCIE.srcs\sources_1\new'
$tests = Join-Path $ProjectRoot 'project_PCIE.srcs\sim_1\ADC_RAW_TX'
$txRoot = Join-Path $sources 'tgd_tx'
$txFiles = @('ad9122_init_rom.v', 'ad9122_config.v', 'ad9122_spi_master.v', 'ad9122_lvds_tx.v',
             'tgd_tx_frontend.v', 'tgd_tx_sample_path.v', 'lfm_phase_source.v', 'lfm_iq_source.v') |
    ForEach-Object { Join-Path $txRoot $_ }
$top = Join-Path $sources 'old_prj_src\top_layer.v'
$driver = Join-Path $sources 'old_prj_src\adc_driver.v'
$glbl = Join-Path (Split-Path $VivadoBin -Parent) 'data\verilog\src\glbl.v'
$cases = @(
    @{ Name='tb_writer_fail_stop'; Phase='Writer'; Marker='WRITER_FAIL_STOP_TEST_PASS';
       Sources=@((Join-Path $sources 'wr_addr.v'), (Join-Path $sources 'das_processing\das_iq_control.v')) },
    @{ Name='tb_raw_capture'; Phase='Raw'; Marker='RAW_CAPTURE_TEST_PASS';
       Sources=@((Join-Path $sources 'das_processing\raw_trace_capture.v'), (Join-Path $sources 'das_processing\das_iq_control.v')) },
    @{ Name='tb_adc_ramp_checker'; Phase='Adc'; Marker='ADC_RAMP_CHECKER_TEST_PASS'; Sources=@($top) },
    @{ Name='tb_adc_test_control'; Phase='Adc'; Marker='ADC_TEST_CONTROL_TEST_PASS'; Sources=@($top)+$txFiles; Primitives=$true },
    @{ Name='tb_adc_driver_primitives'; Phase='Adc'; Marker='ADC_DRIVER_PRIMITIVES_TEST_PASS'; Sources=@($driver); Primitives=$true },
    @{ Name='tb_top_shared_spi_tx'; Phase='Adc'; Marker='TOP_SHARED_SPI_TX_TEST_PASS'; Sources=@($top,$driver)+$txFiles; Primitives=$true },
    @{ Name='tb_adc_capture_monitor'; Phase='Adc'; Marker='ADC_CAPTURE_MONITOR_TEST_PASS'; Sources=@($top) },
    @{ Name='tb_ad9122_config'; Phase='Dac'; Marker='AD9122_CONFIG_TEST_PASS'; Sources=$txFiles; Primitives=$true },
    @{ Name='tb_ad9122_spi_master'; Phase='Dac'; Marker='AD9122_SPI_TEST_PASS'; Sources=$txFiles; Primitives=$true },
    @{ Name='tb_ad9122_lvds_tx'; Phase='Dac'; Marker='AD9122_PHY_TEST_PASS'; Sources=$txFiles; Primitives=$true },
    @{ Name='tb_tgd_tx_sample_path'; Phase='Dac'; Marker='AD9122_SAMPLE_TEST_PASS'; Sources=$txFiles; Primitives=$true },
    @{ Name='tb_tgd_tx_frontend'; Phase='Dac'; Marker='AD9122_FRONTEND_TEST_PASS'; Sources=$txFiles; Primitives=$true }
)
$selected = @($cases | Where-Object { $Phase -eq 'All' -or $_.Phase -eq $Phase })
foreach ($tool in @('xvlog.bat', 'xelab.bat', 'xsim.bat')) {
    if (!(Test-Path -LiteralPath (Join-Path $VivadoBin $tool))) { throw "Missing Vivado tool: $tool in $VivadoBin" }
}
foreach ($case in $selected) {
    foreach ($file in @($case.Sources) + @((Join-Path $tests ($case.Name + '.sv')))) {
        if (!(Test-Path -LiteralPath $file)) { throw "Missing source: $file" }
    }
}
function Invoke-VivadoStep([string]$Tool, [string[]]$Arguments, [string]$LogName) {
    & (Join-Path $VivadoBin $Tool) @Arguments 2>&1 | Tee-Object -FilePath $LogName
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0 -or (Get-Content -LiteralPath $LogName -Raw) -match '(?i)\b(Fatal|Error)\s*:') {
        throw "$Tool failed (exit $exitCode); see $((Get-Location).Path)\$LogName"
    }
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Write-Output "RTL simulation output: $OutputDir"
foreach ($case in $selected) {
    $caseDir = Join-Path $OutputDir $case.Name
    New-Item -ItemType Directory -Path $caseDir -Force | Out-Null
    Push-Location $caseDir
    try {
        Copy-Item -LiteralPath (Join-Path $txRoot 'sine_4096.mem') -Destination 'sine_4096.mem' -Force
        $compileArgs = @('--sv') + @($case.Sources) + @((Join-Path $tests ($case.Name + '.sv')))
        $elaborateArgs = @($case.Name, '-s', $case.Name, '-timescale', '1ns/1ps')
        if ($case.Primitives) {
            $compileArgs += $glbl
            $elaborateArgs = @('-L', 'unisims_ver') + $elaborateArgs + @('glbl')
        }
        Invoke-VivadoStep 'xvlog.bat' $compileArgs 'compile.log'
        Invoke-VivadoStep 'xelab.bat' $elaborateArgs 'elaborate.log'
        Invoke-VivadoStep 'xsim.bat' @($case.Name, '-runall', '-log', 'xsim.log') 'run.log'
        $log = Get-Content -LiteralPath 'xsim.log' -Raw
        if ($log -match '(?i)\b(Fatal|Error)\s*:' -or !$log.Contains($case.Marker)) {
            throw "Missing PASS marker or simulation failure: $($case.Name)"
        }
        Write-Output "CASE_PASS: $($case.Name)"
    } finally { Pop-Location }
}
Write-Output "ACQUISITION_RTL_CHECK_PASS: $($selected.Count) cases ($Phase)"
