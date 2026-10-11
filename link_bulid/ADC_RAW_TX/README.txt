ADC_RAW_TX 是合并后主工程的新构建输出目录。
运行 scripts/build_das.tcl 后，综合检查点、布线检查点、时序/CDC/DRC/I/O 报告和新 bit/LTX 写入此处。
目录存在不表示本版已完成构建。本次合并不以完整实现为 push 门槛，也不声明已有新 bit。
PCIEv2_0 中的旧 bit/LTX 属于历史 DAS 设计，继续原地保留，不能用于验证当前 ADC/RAW/TX 源码。
构建与源码打包说明：../../project_PCIE.doc/ADC_RAW_TX/构建与交付说明.txt。
