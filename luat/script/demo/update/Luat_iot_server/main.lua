--��Ҫ���ѣ����������λ�ö���MODULE_TYPE��PROJECT��VERSION����
--MODULE_TYPE��ģ���ͺţ�Ŀǰ��֧��Air201��Air202��Air800
--PROJECT��ascii string���ͣ�������㶨�壬ֻҪ��ʹ��,����
--VERSION��ascii string���ͣ����ʹ��Luat������ƽ̨�̼������Ĺ��ܣ����밴��"X.X.X"���壬X��ʾ1λ���֣��������㶨��
MODULE_TYPE = "Air202"
PROJECT = "LUAT_IOT_SERVER_UPDATE"
VERSION = "1.0.0"
--[[
ʹ��Luat������ƽ̨�̼������Ĺ��ܣ����밴�����²��������
1����Luat������ƽ̨ǰ��ҳ�棺https://iot.openluat.com/
2�����û���û�����ע���û�
3��ע���û�֮�����û�ж�Ӧ����Ŀ������һ������Ŀ
4�������Ӧ����Ŀ�������ߵ���Ŀ��Ϣ���ұ߻������Ϣ���ݣ��ҵ�ProductKey����ProductKey�����ݣ���ֵ��PRODUCT_KEY����
]]
PRODUCT_KEY = "v32xEAKsGTIEQxtqgwCldp5aPlcnPs3K"
require"sys"
--[[
���ʹ��UART���trace��������ע�͵Ĵ���"--sys.opntrace(true,1)"���ɣ���2������1��ʾUART1���trace�������Լ�����Ҫ�޸��������
�����������������trace�ڵĵط�������д��������Ա�֤UART�ھ����ܵ�����������ͳ��ֵĴ�����Ϣ��
���д�ں��������λ�ã����п����޷����������Ϣ���Ӷ����ӵ����Ѷ�
]]
--sys.opntrace(true,1)
--[[
ʹ��Luat������ƽ̨������������ʱ���������²������
1������updateģ�� require"update"
ִ��������һ�����豸ÿ�ο���������׼�������󣬾ͻ��Զ���������������ִ����������
2�������Ҫ��ʱִ���������ܣ���--update.setperiod(3600)��ע�ͣ������Լ�����Ҫ�����ö�ʱ����
3�������Ҫʵʱִ���������ܣ��ο�--sys.timer_start(update.request,120000)�������Լ�����Ҫ������update.request()����
]]
require"update"
--update.setperiod(3600)
--sys.timer_start(update.request,120000)
require"dbg"
sys.timer_start(dbg.setup,12000,"UDP","ota.airm2m.com",9072)
require"test"
if MODULE_TYPE=="Air201" then
require"wdt"
end

sys.init(0,0)
sys.run()
