project_PCIE：ADC / RAW / DAS / AD9122 TX 合并版本（2026-10-11）

工程入口：project_PCIE.xpr；Vivado 2018.3；xcku060-ffva1156-2-i。
本版保留第一个工程的目录和 DDR4/XDMA/DAS 后端，合入第二个工程的
ADC ramp/连续性监控、RAW1 单帧、AD9122 单次扫频以及 writer 故障停机保护。

当前使用入口：
  python scripts/check_das_bd.py
  powershell -File scripts/test_host.ps1
  powershell -File scripts/run_acquisition_rtl_check.ps1
  vivado -mode batch -source scripts/validate_acquisition.tcl
  vivado -mode batch -source scripts/build_das.tcl

RTL 回归默认使用 D:/Xilinxx/Vivado/2018.3/bin，可用 -VivadoBin 指定工具目录。
主机基础解码使用 Python 3；离线匹配与相关测试还需要 NumPy。
build_das.tcl 会按当前工程位置刷新 ROM 路径，然后生成 BD 并综合、实现。
新增测试位于 project_PCIE.srcs/sim_1/ADC_RAW_TX，不改变默认旧仿真顶层。

操作和格式：project_PCIE.doc/ADC_RAW_TX/HOST_CAPTURE_GUIDE.txt、RAW1_FORMAT.txt。
构建与交付：project_PCIE.doc/ADC_RAW_TX/构建与交付说明.txt。
本次结果：project_PCIE.doc/ADC_RAW_TX/合并验证记录.txt。

新构建输出：link_bulid/ADC_RAW_TX。
历史 DAS bit/LTX 和报告继续保留在 link_bulid/PCIEv2_0；它们不包含本版新增功能。
project_PCIE.doc/PCIEv2_0 是历史版本说明；archive/backups 保存旧迁移基线。
旧 integrate_das_bd.tcl/trim_adc_to_fifo.tcl 等是历史迁移工具，正常构建无需重跑。

当前 RAW 与 TX 每次系统复位只运行一次。首次 start 锁定配置；重新采集需要系统复位。
只有 DDR 最终成功写响应完成后的 frames-done 才能作为发布依据；capture_complete
或 frame_sent 单独为 1 不表示 DDR 已写完。TX 默认关闭，验收顺序为 ADC ramp、
RAW 正常模式、DAC 电测，最后按实物时钟/AOM 参数进行系统标定。

本版数字测试不能替代完整实现、CDC/时序复核和 ADC/DAC 实板验收。
