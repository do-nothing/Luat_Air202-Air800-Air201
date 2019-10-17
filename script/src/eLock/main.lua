---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by li.jun.
--- DateTime: 1/22/2018 9:09 AM
---

MODULE_TYPE = "Air800"
PROJECT = "guide"
VERSION = "1.0.0"
require"sys"
--[[
如果使用UART输出trace，打开这行注释的代码"--sys.opntrace(true,1)"即可，第2个参数1表示UART1输出trace，根据自己的需要修改这个参数
这里是最早可以设置trace口的地方，代码写在这里可以保证UART口尽可能的输出“开机就出现的错误信息”
如果写在后面的其他位置，很有可能无法输出错误信息，从而增加调试难度
]]
--sys.opntrace(true,1)

--加载硬件看门狗功能模块（for s6）
require "wdt"
wdt.setup(pio.P0_30, pio.P0_31)

require "test"

sys.init(0,0)
sys.run()