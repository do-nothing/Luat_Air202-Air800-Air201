module(..., package.seeall)

require 'aLiYun'
require 'misc'
require 'pm'
require 'pins'
require 'audio'

local EOS_ACCOUNT = "liweitest"

local volume = 7

local function print(...)
    _G.print('eloak2 info -->', ...)
end

local setGpio7Fnc = pins.setup(pio.P0_7, 0)
local setGpio6Fnc = pins.setup(pio.P0_6, 0)
local setGpio5Fnc = pins.setup(pio.P0_5, 0)
local setGpio4Fnc = pins.setup(pio.P0_4, 0)
setGpio7Fnc(1)

local PRODUCT_KEY = "a1wHIx75Rf2"
local PRODUCE_SECRET = "IwdNKqpm1tMABBIj"
local function getDeviceName()
    return misc.getImei()
end
local function setDeviceSecret(s)
    misc.setSn(s)
end
local function getDeviceSecret()
    return misc.getSn()
end

--阿里云客户端是否处于连接状态
local sConnected

function getShadow()
    if sConnected then
        print("send request for get shadow...")
        aLiYun.publish(
            "/shadow/update/" .. PRODUCT_KEY .. "/" .. getDeviceName(),
            "{\"method\":\"get\"}",
            1)
    end
end

local function pgio4off()
    setGpio4Fnc(0)
end
local function rcvCbFnc(topic, qos, payload)
    log.info('testALiYun.rcvCbFnc', topic, qos, payload)
    
    local tjsondata, result, errinfo = json.decode(payload)
    local voice
    if result == nil then
        print('json.decode error:', errinfo)
        return
    end
    
    if tjsondata['payload'] then
        print('设备通信正常！')
        EOS_ACCOUNT = tjsondata['payload']['state']['desired']['target']
        volume = tjsondata['payload']['state']['desired']['volume']
        EOS_ACCOUNT = EOS_ACCOUNT and EOS_ACCOUNT or "liweitest"
        volume = volume and volume or 7
    end
    
    voice = tjsondata['voice']
    if voice == nil then
        return
    end
    print("voice-->", voice);
    
    if voice == "request" then
        setGpio5Fnc(1)
    elseif voice == "cancel" then
        setGpio5Fnc(0)
    elseif voice == 'tts' then
        tts = tjsondata['tts']
        audio.play(0, 'TTS', tts, volume)
    else
        audio.play(0, 'FILE', '/ldata/' .. voice .. '.mp3', volume)
    end
    
    if voice == 'aws02' then
        setGpio4Fnc(1)
        sys.timerStart(pgio4off, 2000)
    end
end

--- 连接结果的处理函数
-- @bool result，连接结果，true表示连接成功，false或者nil表示连接失败
local function connectCbFnc(result)
    log.info('testALiYun.connectCbFnc', result)
    sConnected = result
    if result then
        print('设备连接成功！')
        --订阅主题，不需要考虑订阅结果，如果订阅失败，aLiYun库中会自动重连
        aLiYun.subscribe(
            {
                ['/' .. PRODUCT_KEY .. '/' .. getDeviceName() .. '/user/get'] = 0,
                ['/' .. PRODUCT_KEY .. '/' .. getDeviceName() .. '/user/get'] = 1,
                ['/shadow/get/' .. PRODUCT_KEY .. '/' .. getDeviceName()] = 1
            }
        )
        --注册数据接收的处理函数
        aLiYun.on('receive', rcvCbFnc)
        
        sys.timerStart(getShadow, 3000)
        setGpio6Fnc(1)
    end
end

-- 认证结果的处理函数
-- @bool result，认证结果，true表示认证成功，false或者nil表示认证失败
local function authCbFnc(result)
    log.info('testALiYun.authCbFnc', result)
end

--采用一机一密认证方案时：
--配置：ProductKey、获取DeviceName的函数、获取DeviceSecret的函数；其中aLiYun.setup中的第二个参数必须传入nil
--aLiYun.setup(PRODUCT_KEY, nil, getDeviceName, getDeviceSecret)
--采用一型一密认证方案时：
--配置：ProductKey、ProductSecret、获取DeviceName的函数、获取DeviceSecret的函数、设置DeviceSecret的函数
aLiYun.setup(PRODUCT_KEY, PRODUCE_SECRET, getDeviceName, getDeviceSecret, setDeviceSecret)

--setMqtt接口不是必须的，aLiYun.lua中有这个接口设置的参数默认值，如果默认值满足不了需求，参考下面注释掉的代码，去设置参数
--aLiYun.setMqtt(0)
aLiYun.on('auth', authCbFnc)
aLiYun.on('connect', connectCbFnc)

--要使用阿里云OTA功能，必须参考本文件124或者126行aLiYun.setup去配置参数
--然后加载阿里云OTA功能模块(打开下面的代码注释)
require 'aLiYunOta'
--如果利用阿里云OTA功能去下载升级合宙模块的新固件，默认的固件版本号格式为：_G.PROJECT.."_".._G.VERSION.."_"..sys.getcorever()，下载结束后，直接重启，则到此为止，不需要再看下文说明
--如果下载升级合宙模块的新固件，下载结束后，自己控制是否重启
--如果利用阿里云OTA功能去下载其他升级包，例如模块外接的MCU升级包，则根据实际情况，打开下面的代码注释，调用设置接口进行配置和处理
--设置MCU当前运行的固件版本号
--aLiYunOta.setVer("MCU_VERSION_1.0.0")
--设置新固件下载后保存的文件名
--aLiYunOta.setName("MCU_FIRMWARE.bin")
--[[
函数名：otaCb
功能  ：新固件文件下载结束后的回调函数
通过uart1（115200,8,uart.PAR_NONE,uart.STOP_1）把下载成功的文件，发送到MCU，发送成功后，删除此文件
参数  ：
result：下载结果，true为成功，false为失败
filePath：新固件文件保存的完整路径，只有result为true时，此参数才有意义
返回值：无
]]
local function otaCb(result, filePath)
    log.info('testALiYun.otaCb', result, filePath)
    if result then
        local uartID = 1
        sys.taskInit(
            function()
                local fileHandle = io.open(filePath, 'rb')
                if not fileHandle then
                    log.error('testALiYun.otaCb open file error')
                    if filePath then
                        os.remove(filePath)
                    end
                    return
                end
                
                pm.wake('UART_SENT2MCU')
                uart.on(
                    uartID,
                    'sent',
                    function()
                        sys.publish('UART_SENT2MCU_OK')
                    end
                )
                uart.setup(uartID, 115200, 8, uart.PAR_NONE, uart.STOP_1, nil, 1)
                while true do
                    local data = fileHandle:read(1460)
                    if not data then
                        break
                    end
                    uart.write(uartID, data)
                    sys.waitUntil('UART_SENT2MCU_OK')
                end
                --此处上报新固件版本号（仅供测试使用）
                --用户开发自己的程序时，根据下载下来的新固件，执行升级动作
                --升级成功后，调用aLiYunOta.setVer上报新固件版本号
                --如果升级失败，调用aLiYunOta.setVer上报旧固件版本号
                aLiYunOta.setVer('MCU_VERSION_1.0.1')
                
                uart.close(uartID)
                pm.sleep('UART_SENT2MCU')
                fileHandle:close()
                if filePath then
                    os.remove(filePath)
                end
            end
    )
    else
        --文件使用完之后，如果以后不再需求，需要自行删除
        if filePath then
            os.remove(filePath)
        end
    end
end

--设置新固件下载结果的回调函数
--aLiYunOta.setCb(otaCb)
local function closedhandler()
    print("设备已断开！")
    setGpio6Fnc(0)
end
aLiYun.setclosedhandler(closedhandler);

local function checkLink()
    -- 文件系统剩余空间 rtos.get_fs_free_size()
    print("----->", netLed.ledState,misc.getVbatt(),net.getRssi());
end
-- sys.timerLoopStart(checkLink, 3000);

function gpio2IntFnc(msg)
    log.info('testGpioSingle.gpio4IntFnc', msg, getGpio2Fnc())
    if msg == cpu.INT_GPIO_POSEDGE then
        --print("上升沿中断")
        setGpio5Fnc(0)
        print(misc.getImei())
        print(misc.getSn())
    else
        --print("下降沿中断")
        print(EOS_ACCOUNT)
        print(volume)
        aLiYun.publish(
            "/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/update",
            "{\"target\":\"" .. EOS_ACCOUNT .. "\",\"command\":\"ok\"}",
            0)
    end
end
getGpio2Fnc = pins.setup(pio.P0_2, gpio2IntFnc, pio.PULLUP)
