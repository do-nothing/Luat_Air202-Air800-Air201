module(...,package.seeall)

require"common"

--[[
�ӽ����㷨������ɶ���
http://tool.oschina.net/encrypt?type=2
http://www.ip33.com/crc.html
http://tool.chacuo.net/cryptaes
���в���
]]

local slen = string.len

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������aliyuniotǰ׺
����  ����
����ֵ����
]]
local function print(...)
	_G.print("test",...)
end

--[[
��������base64test
����  ��base64�ӽ����㷨����
����  ����
����ֵ����
]]
local function base64test()
	local originstr = "123456crypto.base64_encodemodule(...,package.seeall)sys.timer_start(test,5000)jdklasdjklaskdjklsa"
	local encodestr = crypto.base64_encode(originstr,slen(originstr))
	print("base64_encode",encodestr)
	print("base64_decode",crypto.base64_decode(encodestr,slen(encodestr)))
end

--[[
��������hmacmd5test
����  ��hmac_md5�㷨����
����  ����
����ֵ����
]]
local function hmacmd5test()
	local originstr = "asdasdsadas"
	local signkey = "123456"
	print("hmac_md5",crypto.hmac_md5(originstr,slen(originstr),signkey,slen(signkey)))
end

--[[
��������md5test
����  ��md5�㷨����
����  ����
����ֵ����
]]
local function md5test()
	local originstr = "sdfdsfdsfdsffdsfdsfsdfs1234"
	print("md5",crypto.md5(originstr,slen(originstr)))
end

--[[
��������hmacsha1test
����  ��hmac_sha1�㷨����
����  ����
����ֵ����
]]
local function hmacsha1test()
	local originstr = "asdasdsadasweqcdsjghjvcb"
	local signkey = "12345689012345"
	print("hmac_sha1",crypto.hmac_sha1(originstr,slen(originstr),signkey,slen(signkey)))
end

--[[
��������sha1test
����  ��sha1�㷨����
����  ����
����ֵ����
]]
local function sha1test()
	local originstr = "sdfdsfdsfdsffdsfdsfsdfs1234"
	print("sha1",crypto.sha1(originstr,slen(originstr)))
end

--[[
��������crctest
����  ��crc�㷨����
����  ����
����ֵ����
]]
local function crctest()
	local originstr = "sdfdsfdsfdsffdsfdsfsdfs1234"
	print("crc16_modbus",string.format("%04X",crypto.crc16_modbus(originstr,slen(originstr))))
	print("crc32",string.format("%08X",crypto.crc32(originstr,slen(originstr))))
end

--[[
��������aestest
����  ��aes�㷨����
����  ����
����ֵ����
]]
local function aestest()
	local originstr = "123456crypto.base64_encodemodule(...,package.seeall)sys.timer_start(test,5000)jdklasdjklaskdjklsa"
	--����ģʽ:ECB�����:zeropadding�����ݿ�:128λ
	local encodestr = crypto.aes128_ecb_encrypt(originstr,slen(originstr),"1234567890123456",16)
	print("aes128_ecb_encrypt",common.binstohexs(encodestr))
	print("aes128_ecb_decrypt",crypto.aes128_ecb_decrypt(encodestr,slen(encodestr),"1234567890123456",16))
	
	--cbc����֧��
	--encodestr = crypto.aes128_cbc_encrypt(originstr,slen(originstr),"1234567890123456",16,"1234567890123456",16)
	--print("aes128_cbc_encrypt",common.binstohexs(encodestr))
	--print("aes128_cbc_decrypt",crypto.aes128_cbc_decrypt(encodestr,slen(encodestr),"1234567890123456",16,"1234567890123456",16))
end

--[[
��������test
����  ���㷨�������
����  ����
����ֵ����
]]
local function test()
	base64test()
	hmacmd5test()
	md5test()
	hmacsha1test()
	sha1test()
	crctest()
	aestest()
end

sys.timer_start(test,5000)
