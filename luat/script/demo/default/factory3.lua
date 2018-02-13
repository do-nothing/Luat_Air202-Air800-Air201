--[[
ģ�����ƣ�ģ���������ܲ���
ģ�鹦�ܣ�֧��IMEI��д��SN��д��SIM�����ԡ��ź�ǿ�Ȳ��ԡ�GPIO���ԡ���Ƶ����
ģ������޸�ʱ�䣺2017.05.24
]]

require"misc"
require"net"
require"sim"
require"pm"

module(...,package.seeall)

local UART_ID = 3
local smatch,slen = string.match,string.len
local waitimeirst,waitsnrst,csqshreshold
local tgpio = {}

local function print(...)
	_G.print("factory3",...)
end

local function wake()	
	--sys.timer_start(pm.sleep,300000,"factory")
end

local function rsp(s)
	print("rsp",s)
	--wake()
	uart.write(UART_ID,s)
end

local function imeicb(suc)
	print("imeicb",suc)
	rsp("\r\nAT+WIMEI\r\n"..(suc and "OK" or "ERROR").."\r\n")
end

local function sncb(suc)
	print("sncb",suc)
	rsp("\r\nAT+WISN\r\n"..(suc and "OK" or "ERROR").."\r\n")
end

local function stoptimer(s)
	sys.timer_stop(loopqry,s)
	sys.timer_stop(looptimeout,s)
end

function loopqry(s)
	print("loopqry",s,sim.getstatus(),net.getstate(),net.getrssi(),csqshreshold)
	if s=="SIM" then
		if sim.getstatus() then
			stoptimer(s)
			rsp("\r\nAT+SIM\r\nOK\r\n")
		end
	elseif s=="CREG" then
		if net.getstate()=="REGISTERED" then
			stoptimer(s)
			rsp("\r\nAT+CREG\r\nOK\r\n")
		end
	elseif s=="CSQ" then
		net.csqquery()
		if net.getrssi()>=csqshreshold then
			stoptimer(s)
			rsp("\r\nAT+CSQ\r\nOK\r\n")
		end
	end
end

function looptimeout(s)
	print("looptimeout",s)
	sys.timer_stop(loopqry,s)
	if s=="SIM" then
		rsp("\r\nAT+SIM\r\nERROR\r\n")
	elseif s=="CREG" then
		rsp("\r\nAT+CREG\r\nERROR\r\n")
	elseif s=="CSQ" then
		rsp("\r\nAT+CSQ\r\n"..net.getrssi().."\r\nERROR\r\n")
	end
end

local adc0opn,adc1opn
local uart2close
local function proc(item)
	local s = string.upper(item)
	print("proc",s,waitimeirst,waitsnrst)
	if smatch(s,"AT%+WIMEI=") then
		waitimeirst = true
		misc.setimei(smatch(item,"=\"(.+)\""),imeicb)		
	elseif smatch(s,"AT%+CGSN") then
		local imei = misc.getimei()
		if waitimeirst or imei=="" then
			rsp("\r\nAT+CGSN?\r\nERROR\r\n")
		else			
			rsp("\r\nAT+CGSN?\r\n" .. imei .. "\r\nOK\r\n")
		end
	elseif smatch(s,"AT%+WISN=") then
		waitsnrst = true
		misc.setsn(smatch(item,"=\"(.+)\""),sncb)		
	elseif smatch(s,"AT%+WISN%?") then
		local sn = misc.getsn()
		if waitsnrst --[[ or sn=="" ]]then
			rsp("\r\nAT+WISN?\r\nERROR\r\n")
		else			
			rsp("\r\nAT+WISN?\r\n" .. sn .. "\r\nOK\r\n")
		end
	elseif smatch(s,"AT%+RESTART") then
		waitimeirst,waitsnrst = true,true
		uart.close(UART_ID)
		rtos.restart()
	elseif smatch(s,"AT%+SIM") then
		if _G.MODULE_TYPE~="Air800" then
			if not uart2close then uart2close=true uart.close(2) end
		end
		if sim.getstatus() then
			rsp("\r\nAT+SIM\r\nOK\r\n")
		else
			sys.timer_loop_start(loopqry,1000,"SIM")
			sys.timer_start(looptimeout,tonumber(smatch(item,"=(%d+)"))*1000,"SIM")
		end
	elseif smatch(s,"AT%+CREG") then
		if net.getstate()=="REGISTERED" then
			rsp("\r\nAT+CREG\r\nOK\r\n")
		else
			sys.timer_loop_start(loopqry,1000,"CREG")
			sys.timer_start(looptimeout,tonumber(smatch(item,"=(%d+)"))*1000,"CREG")
		end
	elseif smatch(s,"AT%+CSQ") then
		csqshreshold = tonumber(smatch(item,"=(%d+)"))
		if net.getrssi()>=csqshreshold then
			rsp("\r\nAT+CSQ\r\nOK\r\n")
		else
			sys.timer_loop_start(loopqry,1000,"CSQ")
			sys.timer_start(looptimeout,tonumber(smatch(item,",(%d+)"))*1000,"CSQ")
		end
	elseif smatch(s,"AT%+GPIO") then		
		tgpio = {}
		local k,v,kk
		for v in string.gmatch(item,"(%d+)") do
			table.insert(tgpio,tonumber(v))
		end
		if #tgpio<2 then rsp("\r\nAT+GPIO\r\nERROR\r\n") return end
		net.setled(false)
		if wdt then wdt.close() end
		--��һ����ȫ������Ϊ���룬��ȡ�����ƽ��Ӧ��ȫ��Ϊ�͵�ƽ
		for k=1,#tgpio do
			pio.pin.close(tgpio[k])
			pio.pin.setdir(pio.INPUT,tgpio[k])
		end
		for k=1,#tgpio do
			if pio.pin.getval(tgpio[k])~=0 then
				rsp("\r\nAT+GPIO\r\n1_"..tgpio[k].."\r\nERROR\r\n")
				return
			end
		end
		
		--�ڶ������ӵ�2��gpio��ʼ��������Ϊ����ߣ�ͨ������һ��gpio�ĵ�ƽ����֤����Ƿ���ȷ
		--��ȷ��������Ϊ���룬Ȼ���ȡ����������ƽ��Ӧ��Ϊ�͵�ƽ
		for k=2,#tgpio do
			pio.pin.close(tgpio[k])
			pio.pin.setdir(pio.OUTPUT,tgpio[k])
			pio.pin.setval(1,tgpio[k])
			if pio.pin.getval(tgpio[1])~=1 then
				rsp("\r\nAT+GPIO\r\n2_"..tgpio[k].."\r\nERROR\r\n")
				return
			end
			for kk=2,#tgpio do
				if k~=kk then
					if pio.pin.getval(tgpio[kk])~=0 then
						rsp("\r\nAT+GPIO\r\n3_"..tgpio[kk].."\r\nERROR\r\n")
						return
					end
				end
			end
			pio.pin.close(tgpio[k])
			pio.pin.setdir(pio.INPUT,tgpio[k])
			if pio.pin.getval(tgpio[k])~=0 then
				rsp("\r\nAT+GPIO\r\n4_"..tgpio[k].."\r\nERROR\r\n")
				return
			end
		end
		rsp("\r\nAT+GPIO\r\nOK\r\n")
	elseif smatch(s,"AT%+ADC=%d") then
		local adcid = smatch(s,"AT%+ADC=(%d)")
		adcid = tonumber(adcid)
		if adcid==0 then
			if not adc0opn then adc0opn=true adc.open(adcid) end
		elseif adcid==1 then
			if not adc1opn then adc1opn=true adc.open(adcid) end
		else
			rsp("\r\nAT+ADC="..adcid.."\r\n65535\r\nOK\r\n")
			return
		end		
		local adcval,voltval = adc.read(adcid)
		if voltval and voltval~=0xFFFF then
			voltval = voltval/3
		end
		rsp("\r\nAT+ADC="..adcid.."\r\n"..voltval.."\r\nOK\r\n")
	elseif smatch(s,"AT%+AUDIO") then
		rsp("\r\nAT+AUDIO\r\nOK\r\n")
	end
end

local rdbuf = ""

--[[
��������read
����  ����ȡ���ڽ��յ�������
����  ����
����ֵ����
]]
local function read()
	local s
	while true do
		s = uart.read(UART_ID,"*l",0)
		if not s or string.len(s) == 0 then break end
		print("read",s)
		rdbuf = rdbuf..s
	end
	if smatch(rdbuf,"\r") then
		proc(rdbuf)
		rdbuf = ""
	end
end

uart.setup(UART_ID,921600,8,uart.PAR_NONE,uart.STOP_1,2)
sys.reguart(UART_ID,read)
pm.wake("factory3")
pmd.ldoset(6,pmd.LDO_VMMC)
pmd.ldoset(6,pmd.LDO_VLCD)
pmd.ldoset(7,pmd.LDO_VIB)
--wake()
--sys.timer_loop_start(uart.write,5000,UART_ID,"\r\nTEST\r\n")
