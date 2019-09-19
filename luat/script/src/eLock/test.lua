---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by li.jun.
--- DateTime: 1/29/2018 5:01 PM
---

module(...,package.seeall)

require"aliyuniotssl"
require"misc"
require"audio"
require"pins"

PRODUCT_KEY = "IgW98z2NGr4"
newsn = "AjJnJOPk4m23FLn8VW4gxvYRnbhmawlE"  --air800
--newsn = "rWGfH1dLIkopM8j3CvzTma21N08HE1eY"  --watch
--newsn = "mCKWK8XUDOuUStxCMKYNqQnWhUPzwfGS"  --s5
-- newsn = "rWGfH1dLIkopM8j3CvzTma21N08HE1eY" --s6

PIN8 = {pin=pio.P0_1}
local function pin29cb(v)
	print("pin29cb",v)
end
--第29个引脚：GPIO_6；配置为中断；valid=1
PIN29 = {pin=pio.P0_6,dir=pio.INT,valid=1,intcb=pin29cb}
pins.reg(PIN29)

local function print(...)
    _G.print("guide info -->",...)
end

local function setsn()
    if misc.getsn() ~= newsn then
        misc.setsn(newsn)
    end
end

local function subackcb(usertag,result)
    print("subackcb:",usertag,result)
    audio.play(0,"FILE","/ldata/wel01.mp3",audiocore.VOL7)
end

local function pin8off()
	pins.set(false,PIN8)
end
local function rcvmessagecb(topic,payload,qos)
    print("rcvmessagecb:",topic,payload,qos)
    --aliyuniotssl.publish("/"..PRODUCT_KEY.."/"..misc.getimei().."/update","device receive:"..payload,qos)
    audio.play(0,"FILE","/ldata/" .. payload .. ".mp3",audiocore.VOL7)

    if payload == "aws02" then
        pins.set(true,PIN8)
        sys.timer_start(pin8off,5000)
    end
end

local function connectedcb()
    print("connectedcb")
    --订阅主题
    aliyuniotssl.subscribe({{topic="/"..PRODUCT_KEY.."/"..misc.getimei().."/get",qos=0}, {topic="/"..PRODUCT_KEY.."/"..misc.getimei().."/get",qos=1}}, subackcb, "subscribegetopic")
    --注册事件的回调函数，MESSAGE事件表示收到了PUBLISH消息
    aliyuniotssl.regevtcb({MESSAGE=rcvmessagecb})
end

local function connecterrcb(r)
    print("connecterrcb:",r)
end
audio.play(0,"FILE","/ldata/wel02.mp3",audiocore.VOL7)
--5秒后开始烧写sn
sys.timer_start(setsn,5000)
aliyuniotssl.config(PRODUCT_KEY)
aliyuniotssl.regcb(connectedcb,connecterrcb)
