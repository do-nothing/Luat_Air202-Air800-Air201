--��Ҫ���ѣ����������λ�ö���MODULE_TYPE��PROJECT��VERSION����
--MODULE_TYPE��ģ���ͺţ�Ŀǰ��֧��Air201��Air202��Air800
--PROJECT��ascii string���ͣ�������㶨�壬ֻҪ��ʹ��,����
--VERSION��ascii string���ͣ����ʹ��Luat������ƽ̨�̼������Ĺ��ܣ����밴��"X.X.X"���壬X��ʾ1λ���֣��������㶨��
MODULE_TYPE = "Air202"
PROJECT = "SOCKET_SSL_LONG_CONNECTION"
VERSION = "1.0.0"
require"sys"
--[[
���ʹ��UART���trace��������ע�͵Ĵ���"--sys.opntrace(true,1)"���ɣ���2������1��ʾUART1���trace�������Լ�����Ҫ�޸��������
�����������������trace�ڵĵط�������д��������Ա�֤UART�ھ����ܵ�����������ͳ��ֵĴ�����Ϣ��
���д�ں��������λ�ã����п����޷����������Ϣ���Ӷ����ӵ����Ѷ�
]]
--sys.opntrace(true,1)
--У���������֤��ʱ����Ҫ�õ���ǰϵͳʱ�䣬���Լ���ntp����ģ��ͬ������ʱ��
require"ntp"
require"test"
if MODULE_TYPE=="Air201" then
require"wdt"
end

sys.init(0,0)
ril.request("AT*TRACE=\"DSS\",0,0")
ril.request("AT*TRACE=\"RDA\",0,0")
ril.request("AT*TRACE=\"SXS\",0,0")
sys.run()
