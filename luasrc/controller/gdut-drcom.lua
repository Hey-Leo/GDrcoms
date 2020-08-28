module("luci.controller.gdut-drcom", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/gdut_drcom")then
		return
	end

--	entry({"admin", "network", "gdut-drcom"}, cbi("gdut-drcom"), _("Dr.com"), 100).dependent=true--
--	entry({"admin","gdut-drcom"}, cbi("gdut-drcom"), _("Dr.com"), 3).dependent=true--
	entry({"admin", "services", "gdut-drcom"}, cbi("gdut-drcom"), _("Dr.com"), 58).dependent=true

	entry({"admin","services","gdut-drcom","status"},call("act_status")).leaf=true
end

function act_status()
	local e={}
		e.running=luci.sys.call("pgrep gdut-drcom >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
