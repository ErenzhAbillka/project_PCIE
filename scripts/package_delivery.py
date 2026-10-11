"""Package current ADC/RAW/TX sources; archive integrity is not build acceptance."""
from pathlib import Path
import argparse
import hashlib
import json
import xml.etree.ElementTree as ET
import zipfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--name', default='project_PCIE_ADC_RAW_TX_source.zip')
args = parser.parse_args()
if Path(args.name).name != args.name or not args.name.endswith('.zip'):
    parser.error('--name must be a ZIP filename without a directory')
docs = root / 'project_PCIE.doc/ADC_RAW_TX'
packages = root / 'link_bulid/ADC_RAW_TX/packages'
packages.mkdir(parents=True, exist_ok=True)
archive = packages / args.name
if archive.exists():
    raise SystemExit('Archive exists; preserve it and pass a new --name.')

for item in ET.parse(root / 'project_PCIE.xpr').iter('File'):
    name = item.attrib['Path'].replace('$PSRCDIR', str(root / 'project_PCIE.srcs')).replace('$PPRDIR', str(root))
    if not Path(name).is_file():
        raise SystemExit(f'Missing XPR source: {name}')
for name in ('ku060_tx_pins.tsv', 'tx01_plan.json'):
    if not (docs / name).is_file():
        raise SystemExit(f'Missing ADC_RAW_TX document: {name}')

manifest_path = docs / 'source_package_manifest.json'
selected = ['README.txt', '.gitignore', 'project_PCIE.xpr', 'project_PCIE.srcs', 'project_PCIE.ip_user_files',
            'scripts', 'project_PCIE.doc/ADC_RAW_TX', 'archive/backups']
files = []
for name in selected:
    base = root / name
    for path in ([base] if base.is_file() else base.rglob('*')):
        if not path.is_file() or path == manifest_path:
            continue
        if any(part in {'.Xil', '__pycache__', 'packages'} for part in path.parts):
            continue
        if path.suffix.lower() in {'.pyc', '.bit', '.ltx', '.dcp', '.zip'}:
            continue
        files.append(path)
files = sorted(set(files))
manifest = {
    'scope': 'ADC_RAW_TX source package; no synthesis, implementation or hardware acceptance',
    'historical_outputs': 'PCIEv2_0 outputs remain on disk and are excluded from this package',
    'files': [{'path': p.relative_to(root).as_posix(), 'bytes': p.stat().st_size,
               'sha256': hashlib.sha256(p.read_bytes()).hexdigest()} for p in files],
}
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
files.append(manifest_path)
with zipfile.ZipFile(archive, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=6, allowZip64=True) as z:
    for path in files:
        z.write(path, 'project_PCIE/' + path.relative_to(root).as_posix())
with zipfile.ZipFile(archive) as z:
    if z.testzip() is not None or len(z.namelist()) != len(files):
        raise SystemExit('ZIP integrity check failed')
    for item in manifest['files']:
        if hashlib.sha256(z.read('project_PCIE/' + item['path'])).hexdigest() != item['sha256']:
            raise SystemExit(f'ZIP content mismatch: {item["path"]}')
    if z.read('project_PCIE/' + manifest_path.relative_to(root).as_posix()) != manifest_path.read_bytes():
        raise SystemExit('ZIP manifest mismatch')
sha = hashlib.sha256(archive.read_bytes()).hexdigest()
archive.with_suffix('.zip.sha256').write_text(sha + '  ' + archive.name + '\n', encoding='ascii')
print(json.dumps({'status': 'ADC_RAW_TX_SOURCE_PACKAGE_VERIFY_PASS', 'path': str(archive),
                  'files': len(files), 'sha256': sha, 'new_bitstream_included': False}, ensure_ascii=False))
