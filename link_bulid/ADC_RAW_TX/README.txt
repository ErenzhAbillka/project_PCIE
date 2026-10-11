ADC_RAW_TX 旧XDMA驱动兼容版（2026-10-11）

功能源码：f516efd570b4e2b773d4ae4cc44a419c9db3d38d，feature/fiber，已推送。
bit/LTX与完整综合实现报告在本目录，实际hash见build_manifest.json。
最终WNS +0.083ns / WHS +0.004ns；既有CDC告警仍在。
已通过JTAG下载、8028/BAR32KiB+64KiB识别及本轮单次65536字节C2H。
ADC ramp正式验收失败：每码两拍重复，A/B各8159个坏边沿。
不要将RAW发布/PCIe读取成功解释为ADC、模拟输入或TX已通过。
hardware_evidence保存下载/VIO/PnP日志；raw_c2h_*保存raw.bin及离线诊断。
详细记录：../../project_PCIE.doc/ADC_RAW_TX/20261011_XDMA兼容与上板记录.txt。
JTAG为易失加载，Flash未更新；旧无USER BAR输出保留在ADC_RAW_TX_precompat_20261011。
