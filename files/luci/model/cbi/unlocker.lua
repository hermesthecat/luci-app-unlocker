-- Copyright 2018 Alex D (https://gitlab.com/Nooblord/)
-- This is free software, licensed under the GNU General Public License v3.

-- [REQUIRED STUFF] -----------------------------------------------------------
require "ubus"
---checks if a string represents an ip address
-- @return true or false
function isIpAddressOrSubnet(ip)
 if not ip then return false end
 local a,b,c,d,e=ip:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)/?(%d?%d?)$")
 a=tonumber(a)
 b=tonumber(b)
 c=tonumber(c)
 d=tonumber(d)
 e=tonumber(e)
 if not a or not b or not c or not d then return false end
 if a<0 or 255<a then return false end
 if b<0 or 255<b then return false end
 if c<0 or 255<c then return false end
 if d<0 or 255<d then return false end
 
 if e==nil then
 	return "ip"
 elseif e>0 and e<33 then
 	return "subnet"
 else
 	return false
 end
end
-------------------------------------------------------------------------------

-- [GLOBAL VARS] --------------------------------------------------------------
local torrc = "/etc/tor/torrc"
local customIP4 = "/etc/unlocker.ipv4custom"
local customIP4IPfile = "/etc/unlocker.ipv4ip"
local customIP4IPheader = "create custom_ip hash:ip family inet maxelem 65536\n"
local customIP4NETfile = "/etc/unlocker.ipv4net"
local customIP4NETheader = "create custom_net hash:net family inet maxelem 65536\n"
local makeTorConfigButtonPressed = false
local torrcSampleConfig = 'Log notice syslog\n' ..
						  'DataDirectory /var/lib/tor\n' ..
						  'User tor\n' ..
						  'AutomapHostsOnResolve 1\n' ..
						  'TransPort 0.0.0.0:9040\n' ..
						  'StrictNodes 1\n' ..
						  'ExcludeExitNodes {ru},{ua},{kz},{by}'

local fontred = "<font color=\"red\">"
local fontgreen = "<font color=\"green\">"
local endfont = "</font>"
local bold = "<strong>"
local endbold = "</strong>"
local brtag ="<br />"
local helpicon = '<span class="cbi-value-helpicon"><img src="/luci-static/reso'..
				 'urces/cbi/help.gif" alt="help" /></span>'
local torrcHelp = translate("Exclude your country exit nodes in config. And add TransPort.") ..
				  brtag .. translate("Example: ") .. bold .. brtag ..
				  "Log notice syslog" .. brtag ..
				  "DataDirectory /var/lib/tor" .. brtag ..
				  "User tor" .. brtag ..
				  "AutomapHostsOnResolve 1" .. brtag ..
				  "TransPort 0.0.0.0:9040" .. brtag ..
				  "StrictNodes 1".. brtag ..
				  "ExcludeExitNodes {ru},{ua},{kz},{by}" .. endbold .. brtag ..
				  translate("More info can be found here: ") .. 
				  '<a href="https://gist.github.com/pwnsdx/effd82f4791bf90d8de6">github.com</a>'
-------------------------------------------------------------------------------

-- [VARS INITIALIZATION] ------------------------------------------------------
-- Detect TOR
local torBinary = luci.util.exec("/usr/bin/which tor")
if torBinary ~= "" then
	local torPid = luci.util.exec("/usr/bin/pgrep tor")
	torServiceStatus = luci.util.exec("/bin/ls /etc/rc.d/S??tor 2>/dev/null")
	if torServiceStatus ~= "" then
		torServiceStatusValue = fontgreen .. translate("ENABLED on boot") .. endfont
	else
		torServiceStatusValue = fontred .. translate("NOT ENABLED on boot") .. endfont
	end
	if torPid ~= "" then
		torStatus = bold .. fontgreen .. translate("Tor is Running") .. endfont ..
		" " .. translate("with PID ") .. torPid .. " " ..
		translate("and") .. " " .. torServiceStatusValue .. endbold
	else
		torStatus = bold .. fontred .. translate("Tor is not Running") .. endfont .. " " .. 
		translate("and") .. " " .. torServiceStatusValue .. endbold
	end
else
	torStatus = bold .. fontred .. translate("Tor is not Installed") .. endfont .. endbold
end
-- Detect TOR END

statusHeadline = bold .. translate("Services Status:") .. endbold .. brtag .. 
				 torStatus .. brtag
statusHeadline = ""
-------------------------------------------------------------------------------

-- [SECTION INIT] -------------------------------------------------------------
m = Map("unlocker")
m.title	= translate("Unlocker")
m.description = translate("Unified solution against internet censorship")
s = m:section(TypedSection, "unlocker")
s.anonymous = true
s.addremove = false
s.description = statusHeadline
-------------------------------------------------------------------------------

-- [BASE SETTINGS TAB] --------------------------------------------------------
s:tab("basic",  translate("Base Setting"))
enabled = s:taboption("basic",Flag, "enabled", translate("Enable Unlocker"))
enabled.rmempty = false

iplists = s:taboption("basic",StaticList,"iplists",translate("IPv4 Bypass Lists"),
					  translate("Multiple selection is allowed."))
iplists.widget = "select"
iplists:depends("enabled","1")
iplists:value("RKNIPLIST",translate("Roskomnadzor (Russia)"))
--iplists:value("GFWIPLIST",translate("Great Firewall IPv4 (China)"))
iplists:value("CUSTOMIPLIST",translate("Custom IPv4"))

--dnlists = s:taboption("basic",StaticList,"dnlists",translate("Domain Bypass Lists"),
--					  translate("Requires dnsmasq-full! " ..
--					  			"Multiple selection is allowed."))
--dnlists.widget = "select"
--dnlists:depends("enabled","1")
--dnlists:value("CUSTOMDNLIST",translate("Custom Domain List"))


proxy_mode = s:taboption("basic",ListValue, "proxy_mode", translate("Bypass Mode"),
		translate("Tor is preferred and free but can't deal with UDP traffic"))
proxy_mode:value("D", translate("Disabled"))
proxy_mode:value("T", translate("Use Tor network"))
if luci.util.exec("/usr/bin/which wg") ~= "" then
	proxy_mode:value("W", translate("Use WireGuard VPN"))
end
--proxy_mode:value("S", translate("Use ShadowSocks (TODO)"))
-------------------------------------------------------------------------------

-- [ADVANCED LISTS SETTINGS TAB] ----------------------------------------------
s:tab("listsettings",  translate("Advanced IP-List Settings"))
-- rknListStatus = s:taboption("listsettings",DummyValue,"rknListStatus",
-- 							translate("Roskomnadzor"))
-- rknListStatus:depends("iplists","RKNIPLIST")
-- gfwListStatus:depends("iplists","GFWIPLIST")
-- rknListStatus.rawhtml = true
-- function rknListStatus.cfgvalue(self, section)
-- 	return bold .. translate("Status: (TODO)") .. endbold
-- end

rknListOptions = s:taboption("listsettings",MultiValue,"rknListOptions",
				   translate("Roskomnadzor (Russia)"))
--				   translate("Currently list is just loaded on boot."))
rknListOptions:depends("iplists","RKNIPLIST")
rknListOptions:depends("iplists","GFWIPLIST")
rknListOptions:value("RKNLISTCRON",translate("Enable list auto-update"))

-- gfwListStatus = s:taboption("listsettings",DummyValue,"gfwListStatus",
-- 							translate("Great Firewall"))
-- gfwListStatus:depends("iplists","GFWIPLIST")
-- gfwListStatus:depends("iplists","RKNIPLIST")
-- gfwListStatus.rawhtml = true
-- function gfwListStatus.cfgvalue(self, section)
-- 	return bold .. translate("Status: (TODO)") .. endbold
-- end

-- gfwListOptions = s:taboption("listsettings",MultiValue,"gfwListOptions",
-- 				   translate("Great Firewall IPv4 (China)"))
-- gfwListOptions:depends("iplists","RKNIPLIST")
-- gfwListOptions:depends("iplists","GFWIPLIST")
-- gfwListOptions:value("GFWLISTCRON",translate("Enable list auto-update"))

customListOptions = s:taboption("listsettings",TextValue, "customListOptions",
	translate("Custom IPv4"),translate("Example:") .. brtag .. bold ..
							 "123.123.123.123" .. brtag ..
							 "143.143.143.143" .. brtag ..
							 "111.111.111.0/24" .. endbold
							 )
customListOptions:depends("iplists","RKNIPLIST")
customListOptions:depends("iplists","GFWIPLIST")
customListOptions:depends("iplists","CUSTOMIPLIST")
customListOptions.rmempty=true
customListOptions.rows=15
customListOptions.wrap = "on"

-- function customListOptions.cfgvalue(self, section)
-- 	return translate("Not ready yet...")
-- end
-- function customListOptions.write(self, section, value)
-- end

function customListOptions.cfgvalue(self, section)
	if nixio.fs.access(customIP4) then
		return nixio.fs.readfile(customIP4)
	else
		return ""
	end
end
function customListOptions.write(self, section, value)
	if value == nil or value == '' then 
		nixio.fs.writefile(customIP4, "")
		if nixio.fs.access(customIP4NETfile) then
			nixio.fs.remove(customIP4NETfile)
		end
		if nixio.fs.access(customIP4IPfile) then
			nixio.fs.remove(customIP4IPfile)
		end
		if nixio.fs.access(customIP4) then
			nixio.fs.remove(customIP4)
		end
	--elseif nixio.fs.access(customIP4) then
	else
		value = value:gsub("\r\n?", "\n")
		newvalue,customIPValue,customIPNETValue="","",""
		for line in value:gmatch("[^\r\n]+") do
			test = isIpAddressOrSubnet(line)
			if test == "ip" then
				newvalue = newvalue .. line .. "\n"
				customIPValue = customIPValue .. "add custom_ip " .. line .. "\n"
			elseif test == "subnet" then
				newvalue = newvalue .. line .. "\n"
				customIPNETValue = customIPNETValue .. "add custom_net " .. line .. "\n"
			end
		end
		value=newvalue
		if nixio.fs.access(customIP4) then
			local old_value = nixio.fs.readfile(customIP4)
		else
			local old_value = "Not empty"
		end

		if value ~= old_value then
			if value ~= "" then
				nixio.fs.writefile(customIP4, value)
			elseif nixio.fs.access(customIP4) then
				nixio.fs.remove(customIP4)
			end
			if customIPValue ~= "" then
				customIPValue = customIP4IPheader .. customIPValue
				nixio.fs.writefile(customIP4IPfile, customIPValue)
			elseif nixio.fs.access(customIP4IPfile) then
				nixio.fs.remove(customIP4IPfile)
			end			
			if customIPNETValue ~= "" then
				customIPNETValue = customIP4NETheader .. customIPNETValue
				nixio.fs.writefile(customIP4NETfile, customIPNETValue)
			elseif nixio.fs.access(customIP4NETfile) then
				nixio.fs.remove(customIP4NETfile)
			end
		end
	-- elseif not nixio.fs.access(customIP4) then
	-- 	nixio.fs.writefile(customIP4, value)
	end
end

-------------------------------------------------------------------------------


-- [TOR CONFIGURATION TAB] ----------------------------------------------------
s:tab("torConfig", translate("Tor Configuration"))
torrcStatus = s:taboption("torConfig",DummyValue, "torrcStatus", " ")
torrcStatus.rawhtml = true
function torrcStatus.cfgvalue(self, section)
	return torStatus
end
torrcStatus:depends("proxy_mode","T")

if torBinary ~= "" then
	torrcButtonRestart = s:taboption("torConfig",Button,"Restart Tor"," ")
	torrcButtonRestart:depends("proxy_mode","T")
	torrcButtonRestart.inputtitle=translate("Restart Tor")
	function torrcButtonRestart.write() 
		luci.sys.exec("/etc/init.d/tor restart")
		luci.sys.exec("sleep 1")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "unlocker"))
	end
	torrcButtonRemove = s:taboption("torConfig",Button,"Uninstall Tor"," ")
	torrcButtonRemove:depends("proxy_mode","T")
	torrcButtonRemove.inputtitle=translate("Uninstall Tor")
	torrcButtonRemove.inputstyle="remove"
	function torrcButtonRemove.write() 
		luci.sys.exec("/bin/opkg --force-removal-of-dependent-packages " ..
			          "remove tor && rm -f /etc/tor/torrc")
		luci.sys.exec("sleep 1")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "unlocker"))
	end
	if torServiceStatus ~= "" then
		torrcButtonDisable = s:taboption("torConfig",Button,"Disable start on boot"," ")
		torrcButtonDisable:depends("proxy_mode","T")
		torrcButtonDisable.inputtitle=translate("Disable start on boot")
		torrcButtonDisable.inputstyle="remove"
		function torrcButtonDisable.write() 
			luci.sys.exec("/etc/init.d/tor disable")
			luci.sys.exec("sleep 1")
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "unlocker"))
		end
	else
		torrcButtonEnable = s:taboption("torConfig",Button,translate("Enable start on boot")," ")
		torrcButtonEnable:depends("proxy_mode","T")
		torrcButtonEnable.inputtitle=translate("Enable start on boot")
		torrcButtonEnable.inputstyle="apply"
		function torrcButtonEnable.write() 
			luci.sys.exec("/etc/init.d/tor enable")
			luci.sys.exec("sleep 1")
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "unlocker"))
		end
	end
	if nixio.fs.access(torrc) then
		torrcButtonConfig = s:taboption("torConfig",Button,translate("Make me Tor config")," ",
										translate("Creates a simple Tor config for unlocker"))
		torrcButtonConfig:depends("proxy_mode","T")
		torrcButtonConfig.inputtitle=translate("Make me Tor config")
		torrcButtonConfig.inputstyle="apply"
		function torrcButtonConfig.write()
			makeTorConfigButtonPressed = true
			nixio.fs.writefile(torrc, torrcSampleConfig)
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "unlocker"))
		end
	end	
else
	torrcButtonInstall = s:taboption("torConfig",Button,"Install Tor",
						" ","Please press ONLY ONCE and wait (approx 20 sec)")
	torrcButtonInstall:depends("proxy_mode","T")
	torrcButtonInstall.inputtitle=translate("Install Tor")
	function torrcButtonInstall.write() 
		luci.sys.exec("/bin/opkg update && /bin/opkg install tor-geoip")
		luci.sys.exec("sleep 1")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "unlocker"))
	end
end


if nixio.fs.access(torrc) then
	torrcConfig = s:taboption("torConfig",TextValue, "torrcConfig",
		translate("Direct edit of torrc file"),torrcHelp)
	torrcConfig:depends("proxy_mode","T")
	torrcConfig.optional = true
	torrcConfig.rmempty=true
	torrcConfig.rows=15
	torrcConfig.wrap = "off"

	function torrcConfig.cfgvalue(self, section)
		if nixio.fs.access(torrc) then
			return nixio.fs.readfile(torrc)
		else
			return "No torrc file."
		end
	end
	function torrcConfig.write(self, section, value)
		if value == nil or value == '' then 
		elseif nixio.fs.access(torrc) then
			value = value:gsub("\r\n?", "\n")
			local old_value = nixio.fs.readfile(torrc)
			if value ~= old_value and not makeTorConfigButtonPressed then
				nixio.fs.writefile(torrc, value)
			end
		end
	end
end

-------------------------------------------------------------------------------

-- [ LOGS TAB] ----------------------------------------------------------------
s:tab("logs",translate("Logs"))
logsUnlocker = s:taboption("logs",TextValue, "logsUnlocker",
	translate("Unlocker log"))
logsUnlocker:depends("enabled","1")
logsUnlocker.rmempty=true
logsUnlocker.rows=15
logsUnlocker.wrap = "on"
function logsUnlocker.cfgvalue(self, section)
	return luci.util.exec("/sbin/logread -e UNLOCKER")
end
function logsUnlocker.write(self, section, value)
end


logsTor = s:taboption("logs",TextValue, "logsTor",
	translate("Tor log"))
logsTor:depends("proxy_mode","T")
--logsTor.readonly = "readonly"
logsTor.rmempty=true
logsTor.rows=15
logsTor.wrap = "on"

function logsTor.cfgvalue(self, section)
	return luci.util.exec("/sbin/logread -e tor")
end
function logsTor.write(self, section, value)
end

-------------------------------------------------------------------------------

if luci.http.formvalue("cbi.apply") then
	luci.sys.exec("sleep 5 && /etc/init.d/unlocker restart >/dev/null 2>&1 &")
end

return m