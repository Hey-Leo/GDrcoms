require("luci.sys")

m = Map("gdut_drcom", translate("Dr.com"), translate("Dr.com is the client that emulates PC Dr.com to send heartbeat packets."))

m:section(SimpleSection).template  = "gdut-drcom/gdut-drcom_status"


local router_ip = luci.sys.exec("uci get network.lan.ipaddr")

s = m:section(TypedSection, "gdut_drcom", translate("客户端配置"),
translate("LuCI版本的Dr.COM配置.")..
"<br />"

.. "<br>系统状态概览：<a href='http://" .. router_ip .. "/cgi-bin/luci/admin/status/overview'>" ..translate("概览")
..[[</a>]]
.. "<br>无线WiFi状态：<a href='http://" .. router_ip .. "/cgi-bin/luci/admin/network/wireless'>" ..translate("无线")
..[[</a>]]
.. "<br>定时重启：<a href='http://" .. router_ip .. "/cgi-bin/luci/admin/system/autoreboot'>" ..translate("定时重启")
..[[</a>]]
.. "<br>文件传输：<a href='http://" .. router_ip .. "/cgi-bin/luci/admin/system/filetransfer'>" ..translate("文件传输")
..[[</a>]]
.. "<br>备份升级：<a href='http://" .. router_ip .. "/cgi-bin/luci/admin/system/flashops'>" ..translate("备份升级")
..[[</a>]]

..[[<br /><br /><strong>]]
..[[<a href="http://222.200.98.8:1800/Dr.COM/Client/Dr.Com.zip" target="_blank">]]
..translate("下载Dr.com客户端")
..[[</a>]]
..[[</strong><br />]]
..[[<br /><strong>]]
..[[<a href="http://222.200.98.8:1800/Self/nav_login" target="_blank">]]
..translate("Guangdong University Of Technology campus network self-service system")
..[[</a>]]
..[[</strong><br />]]
..[[<br /><strong>]]
..[[<a href="https://github.com/drcoms/drcom-generic/tree/master/openwrt" target="_blank">]]
..translate("查看本页面的相关自定义修改和配置说明。")
..[[</a>]]
..[[</strong><br />]]

)
s.anonymous = true


s = m:section(TypedSection, "gdut_drcom", "General Settings")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable", translate("Enable Dr.com client"))

enabledial = s:option(Flag, "enabledial", translate("Enable PPPoE Dial"))
enabledial.default = enabledial.enabled

interface = s:option(ListValue, "interface", translate("Interface"), translate("Please select your dial interface. (Generally it's named WAN/wan)"))
interface:depends("enabledial", "1")
cur = luci.model.uci.cursor()
net = cur:get_all("network")
for k, v in pairs(net) do
	for k1, v1 in pairs(v) do
		if v1 == "interface" then
			interface:value(k)
			if k == "WAN" or k == "wan" then
				interface.default = k
			end
		end
	end
end

username = s:option(Value, "username", translate("Username"),translate("Campus Network Account."))
username:depends("enabledial", "1")

password = s:option(Value, "password", translate("Password"),translate("Account password."))
password:depends("enabledial", "1")
password.password = true


s = m:section(TypedSection, "gdut_drcom", "Advanced Settings", translate(""))
s.addremove = false
s.anonymous = true

macaddr = s:option(Value, "macaddr", translate("MAC address"),translate("WAN/wan port MAC is used by default if left blank, you can also use the MAC on your computer. <br> MAC address format: Ma:C0:0A:Dd:36:EE"))
macaddr.datatype="macaddr"

remote_ip = s:option(Value, "remote_ip", translate("Remote ip"),translate("Choose or customize according to your school district."))
remote_ip.datatype="ipaddr"
remote_ip:value("10.0.3.2", translate("Higher Education Mega Center Campus"))
remote_ip:value("10.0.3.6", translate("Longdong Campus / Dongfeng Road Campus"))

keep_alive_flag = s:option(Value, "keep_alive1_flag", translate("Keep alive1 flag"),translate("The flag bits used to configure the first set of packets, If not set, the default is 00."))

enable_crypt = s:option(Flag, "enable_crypt", translate("Enable crypt"),translate("Used to configure whether the first set of packets is checked with encryption, or not, the default is not encrypted."))


s = m:section(TypedSection, "gdut_drcom", "Disclaimer", translate("Please follow the manual rules of campus network. If you violate the regulations, you should assume the corresponding responsibility."))
s.addremove = false
s.anonymous = true

s:tab("AnQuan", translate("用户责任书"))
AnQuan = s:taboption("AnQuan", Value, "AnQuan", translate("责任书"), translate("校园网学生用户责任书"))
AnQuan.template = "cbi/tvalue"
AnQuan.rows = 23
AnQuan.rmempty = true
AnQuan.readonly="readonly"
function AnQuan.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/config/ZeRen")
end

s:tab("ChengNuo", translate("网络安全承诺书"))
ChengNuo = s:taboption("ChengNuo", Value, "ChengNuo", translate("承诺书"), translate("网络安全承诺书"))
ChengNuo.template = "cbi/tvalue"
ChengNuo.rows = 23
ChengNuo.rmempty = true
ChengNuo.readonly="readonly"
function ChengNuo.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/config/ChengNuo")
end


local apply = luci.http.formvalue("cbi.apply")
if apply then
	io.popen("/etc/init.d/gdut-drcom restart")
end

return m

