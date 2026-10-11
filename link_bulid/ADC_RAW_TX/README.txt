当前正式交付：AD9643严格PN9/SPI读回，2026-10-11

正式完整固件验收（2026-10-11）
Vivado2018.3完整综合、布局布线与post-route复核通过；使用两份既有DDR4 IP缓存，
并通过真实dbg_hub OOC综合恢复WSH launcher失败，不属于无缓存全新构建。
WNS/WHS=+0.083/+0.004ns，ADC14lane setup/hold最差+0.883/+0.932ns；
DAC32port setup/hold最差+0.083/+0.050ns。65位快照相应C到D路径全部通过。
224个I/O管脚一致，119150条网络全部布通。DRC0 error/0 critical/8 warning。
CDC-1由239增至304：新增64条VIO内部hold到64bit读回probe CE及1条SPI SDA输入；
不表示CDC零告警，报告与对应约束/路径审查保存在本地输出中。

本轮正式bit已JTAG下载（未写Flash）。上电PN9检查375000317对，错误0/sticky0；
持续PN9额外检查28497828对，错误0/sticky0；退出正常ADC模式通过。
SPI正常/PN9实际读回bundle分别0100000500000382/0300000506000382。
Windows实际识别10EE:8028，ProblemCode0，原XDMA驱动hash保持不变；
BAR0=F43E8000..F43EFFFF（32KiB用户），BAR1=F43F0000..F43FFFFF（64KiB控制）。
实际协商Gen2 x4；设计上限Gen2 x8不能当成实际x8。

同一不中断运行先确认DDR最终写响应完成，然后单次C2H读取DDR0x100000处65536字节，
没有H2C写入、重试或在途复位；读后VIO再次核对epoch/config/全部故障位为0。
RAW1 epoch=6ACB4749，config=504E3039，stride1，test_mode6，16320对原始样本。
主机按固定XOR3FFF、每样本15bit推进的PN9严格解码，A/B各16320样本零错；
未做重复删除、抽样、相位搜索或错误后重锁。
raw.bin SHA256：17945D3F8DACBFDFB37647678F70C7DB53F180C60D13A4AE61212A2FDF584837。
bit SHA256：51EC228971CAB810FD96A6192007980987F9F5F23E8D1F92F825490AD55A8FEB。
LTX SHA256：8169BD52C728E68A74FF5DC6361013B3237379BA746D6B7487EA069304D804BB。
离线13项RTL、17项主机回归及旧DAS回归通过；独立源码副本的BD生成/完整wrapper展开通过。

验收范围：严格PN9数字接收、DDR发布和PCIe传输通过；0F斜坡重复根因未解决。
ADC未接模拟输入，尚未验证模拟带宽、SNR、采样眼图裕量、真实采样频率及光学链路。
当前TX仍为5..15MHz/20us，未配置200MHz AOM驱动。交付后默认TX关闭、采集未启动。
详细原始日志/数据/检查点位于link_bulid/ADC_RAW_TX；本地大产物不上传Git。

下载使用xdma_pcie_wrapper.bit与同名.ltx配对。已JTAG测试，不掉电保存。
重新采集需重新初始化；下载前先正常禁用PCIe设备，下载后重新枚举。
保留旧ADC_RAW_TX_prePN9_*目录用于回溯，不要误下载旧斜坡失败图像。

交付目录重下载与重启恢复（2026-10-11，16:37核对）
已从A工程link_bulid/ADC_RAW_TX重新下载同hash正式bit/LTX，JTAG成功。
该次正常禁用/删除端点并扫描父PCI桥未恢复8028；一次全局扫描与仅FPGA独占的
下游端口正常restart也未恢复，未扩大至含网络/USB/SATA的上游端口、未自动重启。
ADC init_done=0及SPI读回0与PCIe axi_aresetn=0同时出现；BD复位链会因此保持
采集模块复位，不能把此状态单独解释为ADC故障。
用户正常重启Windows后，未再次下载bit即恢复唯一8028/ProblemCode0/原XDMA驱动；
实际Gen2 x4，资源改为F44E8000..F44EFFFF（32KiB）及F44F0000..F44FFFFF（64KiB）。
JTAG确认PCIe link_up=1/axi_aresetn=1；上电PN9检查375001468对零错，
连续PN9额外检查26095609对零错，退出正常ADC成功。
最终DDRcal=1/ADCinit=1，全部故障0，start=0/test=0/TX=0，采集配置未锁定。
首次65536字节整帧验收及其epoch6ACB4749证据仍单独保留；重启后未再执行DMA。
本机JTAG重新下载后的热枚举并非每次成功；如正常扫描仍无端点，应正常重启
Windows并保持FPGA供电后重新核验。JTAG配置未写Flash，板卡掉电需重新下载。
这项恢复流程不表示0F斜坡重复根因或DAC/光学链路已解决。
