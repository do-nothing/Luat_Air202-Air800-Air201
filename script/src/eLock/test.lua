---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by li.jun.
--- DateTime: 1/29/2018 5:01 PM
---

module(..., package.seeall)

require 'aliyuniotssl'
require 'misc'
require 'audio'
require 'pins'

-- PRODUCT_KEY = 'IgW98z2NGr4'
PRODUCT_KEY = 'a1wHIx75Rf2' -- elock
-- newsn = 'AjJnJOPk4m23FLn8VW4gxvYRnbhmawlE' --air800
-- newsn = "rWGfH1dLIkopM8j3CvzTma21N08HE1eY"  --watch
-- newsn = "fCWgxisAf0AgtGIPkIjqKyxbOldZpzjs"  --s5
-- newsn = "6MtvObCDInG78mzGinQq2WmrzIzvvjbK" --s6
newsn = "nWLL0AmrJv7j613HvH2XFpiRR9EO8eeS" --20191021_1
EOS_ACCOUNT = "unknow"

PIN7 = {pin = pio.P0_6} --����ָʾ��
PIN8 = {pin = pio.P0_4} --�̵���
PIN9 = {pin = pio.P0_5} --ǩ������ָʾ��
PIN10 = {pin = pio.P0_7} --����ָʾ��
PIN11 = {pin = pio.P0_3} --�ߵ�λ
pins.set(false, PIN7)
pins.set(true, PIN10)
pins.set(true, PIN11)
local function pin29cb(v)
    print('pin29cb', v)
    print(misc.getimei())

    if v then
        aliyuniotssl.publish("/"..PRODUCT_KEY.."/"..misc.getimei().."/user/update","{\"target\":\""..EOS_ACCOUNT.."\",\"command\":\"ok\"}",1)
        pins.set(false, PIN9)
        print("isConnect:", aliyuniotssl.mqttssl.isConnect)
        print("EOS_ACCOUNT",EOS_ACCOUNT)
    end
end
--��29�����ţ�GPIO_6������Ϊ�жϣ�valid=1
PIN29 = {pin = pio.P0_2, dir = pio.INT, valid = 1, intcb = pin29cb}
pins.reg(PIN29)

local function print(...)
    _G.print('eloak info -->', ...)
end

local function setsn()
    if misc.getsn() ~= newsn then
        misc.setsn(newsn)
    end
end

local function subackcb(usertag, result)
    print('subackcb:', usertag, result)
    pins.set(true, PIN7)
    aliyuniotssl.publish("/shadow/update/"..PRODUCT_KEY.."/"..misc.getimei(),"{\"method\":\"get\"}",1);
    audio.play(0, 'FILE', '/ldata/wel01.mp3', audiocore.VOL7)
end

local function pin8off()
    pins.set(false, PIN8)
end
local function rcvmessagecb(topic, payload, qos)
    print('rcvmessagecb:', topic, payload, qos)

    local tjsondata, result, errinfo = json.decode(payload)
    local voice
    if result then
        if tjsondata['payload'] then
            EOS_ACCOUNT = tjsondata['payload']['state']['desired']['target']
        end
        voice = tjsondata['voice']
        if voice == nil then
            return
        end
        print("voice-->",voice);
    else
        print('json.decode error:', errinfo)
        return
    end

    if voice == "request" then
        pins.set(true, PIN9)
    elseif voice == "cancel" then
        pins.set(false, PIN9)
    elseif voice == 'tts' then
        tts = tjsondata['tts']
        audio.play(0, 'TTS', common.binstohexs(common.utf8toucs2(tts)), audiocore.VOL7)
    else
        audio.play(0, 'FILE', '/ldata/' .. voice .. '.mp3', audiocore.VOL7)
    end

    if voice == 'aws02' then
        pins.set(true, PIN8)
        sys.timer_start(pin8off, 5000)
    end
end

local function connectedcb()
    print('�豸���ӳɹ���')
    --��������
    aliyuniotssl.subscribe(
        {
            {topic = '/' .. PRODUCT_KEY .. '/' .. misc.getimei() .. '/user/get', qos = 0},
            {topic = '/' .. PRODUCT_KEY .. '/' .. misc.getimei() .. '/user/get', qos = 1},
            {topic = '/shadow/get/' .. PRODUCT_KEY .. '/' .. misc.getimei(), qos = 1}
        },
        subackcb,
        'subscribegetopic'
    )
    --ע���¼��Ļص�������MESSAGE�¼���ʾ�յ���PUBLISH��Ϣ
    aliyuniotssl.regevtcb({MESSAGE = rcvmessagecb})
end

local function connecterrcb(r)
    print('connecterrcb:', r)
    pins.set(false, PIN7)
end
local function closedhandler()
    print("�豸�ѶϿ���")
    pins.set(false, PIN7)
end

aliyuniotssl.mqttssl.setclosedhandler(closedhandler);


audio.play(0, 'FILE', '/ldata/wel02.mp3', audiocore.VOL7)
--5���ʼ��дsn
sys.timer_start(setsn, 5000)
aliyuniotssl.config(PRODUCT_KEY)
aliyuniotssl.regcb(connectedcb, connecterrcb)