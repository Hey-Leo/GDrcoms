--[[
LuCI - Lua Configuration Interface
Copyright 2010 Jo-Philipp Wich <xm@subsignal.org>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
]]--

require("luci.sys")

m = Map("gdut_drcom", translate("Dr.com"), translate("Configure client."))

m:section(SimpleSection).template  = "gdut-drcom/gdut-drcom_status"

s = m:section(TypedSection, "gdut_drcom", "General version_(p) Settings")
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

macaddr = s:option(Value, "macaddr", translate("Mac address"),translate("WAN/wan port Mac is used by default if left blank, you can also use the Mac on your computer. <br> Mac address format: Ma:c0:0A:dd:re:ss"))
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
AnQuan = s:taboption("AnQuan", Value, "AnQuan", translate("责任书"), translate("广东工业大学校园网学生用户责任书"))
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


s = m:section(TypedSection, "gdut_drcom", "Link", translate("广东工业大学校园网自助服务系统：http://222.200.98.8:1800/Self/nav_login"))
s.addremove = false
s.anonymous = true

local apply = luci.http.formvalue("cbi.apply")
if apply then
	io.popen("/etc/init.d/gdut-drcom restart")
end

return m
