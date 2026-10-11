param(
    [string]$Python = 'python',
    [string]$RtlFrame = ''
)
$ErrorActionPreference = 'Stop'
$previousBytecode = $env:PYTHONDONTWRITEBYTECODE
$env:PYTHONDONTWRITEBYTECODE = '1'
try {
    foreach ($test in @('test_decode_das.py', 'test_decode_raw.py')) {
        & $Python -B (Join-Path $PSScriptRoot $test)
        if ($LASTEXITCODE -ne 0) { throw "Host regression failed: $test" }
    }
    if ($RtlFrame) {
        & $Python -B (Join-Path $PSScriptRoot 'check_rtl_raw.py') $RtlFrame
        if ($LASTEXITCODE -ne 0) { throw 'RAW RTL-to-host cross-check failed' }
    }
    Write-Output 'HOST_REGRESSION_PASS'
} finally {
    $env:PYTHONDONTWRITEBYTECODE = $previousBytecode
}
