---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by li.jun.
--- DateTime: 1/29/2018 5:01 PM
---

module(...,package.seeall)

require"aliyuniotssl"
require"misc"
require"audio"

PRODUCT_KEY = "0S9dtdoet7C"
--newsn = "iYRmZ9fd2E0BnwiwxaP6oAxsUlETedls"  --air800
--newsn = "UdSfAzmAGfZ10ALLgHunHOhmIx5kouTQ"  --watch
--newsn = "mCKWK8XUDOuUStxCMKYNqQnWhUPzwfGS"  --s5
newsn = "omZB6M8yuMLKd170X4U3wbJgLu1obRyf" --s6

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
    audio.play(0,"FILE","/ldata/welcome_2.mp3",audiocore.VOL7)
end

local function rcvmessagecb(topic,payload,qos)
    print("rcvmessagecb:",topic,payload,qos)
    --aliyuniotssl.publish("/"..PRODUCT_KEY.."/"..misc.getimei().."/update","device receive:"..payload,qos)
    audio.play(0,"FILE","/ldata/" .. payload .. ".mp3",audiocore.VOL7)
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
audio.play(0,"FILE","/ldata/welcome_1.mp3",audiocore.VOL7)
--5秒后开始烧写sn
sys.timer_start(setsn,5000)
aliyuniotssl.config(PRODUCT_KEY)
aliyuniotssl.regcb(connectedcb,connecterrcb)