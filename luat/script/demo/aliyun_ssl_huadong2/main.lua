--��Ҫ���ѣ����������λ�ö���MODULE_TYPE��PROJECT��VERSION����
--MODULE_TYPE��ģ���ͺţ�Ŀǰ��֧��Air201��Air202��Air800
--PROJECT��ascii string���ͣ�������㶨�壬ֻҪ��ʹ��,����
--VERSION��ascii string���ͣ����ʹ��Luat������ƽ̨�̼������Ĺ��ܣ����밴��"X.X.X"���壬X��ʾ1λ���֣��������㶨��
MODULE_TYPE = "Air202"
PROJECT = "ALIYUN_SSL_HUADONG2"
VERSION = "1.0.1"
--Air�ڲ���������Ϊtrue
--DEBUG_AIR = true
require"sys"
--[[
���ʹ��UART���trace��������ע�͵Ĵ���"--sys.opntrace(true,1)"���ɣ���2������1��ʾUART1���trace�������Լ�����Ҫ�޸��������
�����������������trace�ڵĵط�������д��������Ա�֤UART�ھ����ܵ�����������ͳ��ֵĴ�����Ϣ��
���д�ں��������λ�ã����п����޷����������Ϣ���Ӷ����ӵ����Ѷ�
]]
--sys.opntrace(true,1)
require"test"
if MODULE_TYPE=="Air201" then
require"wdt"
end

sys.init(0,0)
if DEBUG_AIR then
	ril.request("AT*EXASSERT=1")
	ril.request("AT*TRACE=\"DSS\",1,0")
	ril.request("AT*TRACE=\"RDA\",1,0")
	ril.request("AT*TRACE=\"SXS\",1,0")
end
sys.run()
