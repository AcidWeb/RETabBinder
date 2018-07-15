local _G = _G
local _, RE = ...
_G.RETabBinder = RE

local print = _G.print
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local GetCurrentBindingSet = _G.GetCurrentBindingSet
local GetZonePVPInfo = _G.GetZonePVPInfo
local GetBindingKey = _G.GetBindingKey
local GetBindingAction = _G.GetBindingAction
local SetBinding = _G.SetBinding
local SaveBindings = _G.SaveBindings
local ElvUI = _G.ElvUI

RE.AceConfig = {
	type = "group",
	args = {
		DefaultKey = {
			name = "Use default bindings",
			desc = "Disable to use bindings other than TAB/Shift-TAB.",
			type = "toggle",
			width = "full",
			order = 1,
			set = function(_, val) RE.Settings.DefaultKey = val; RE:OnEvent(nil, "ZONE_CHANGED_NEW_AREA") end,
			get = function(_) return RE.Settings.DefaultKey end
		},
	}
}
RE.DefaultConfig = {
	DefaultKey = true
}
RE.Fail = false

local function ElvUISwag(sender)
  if sender == "Livarax-BurningLegion" then
    return [[|TInterface\PvPRankBadges\PvPRank09:0|t ]]
  end
  return nil
end

function RE:OnLoad(self)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("DUEL_REQUESTED")
	self:RegisterEvent("DUEL_FINISHED")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("ADDON_LOADED")
end

function RE:OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and ... == "RETabBinder" then
		if not _G.RETabBinderSettings then
			_G.RETabBinderSettings = RE.DefaultConfig
		end
		if ElvUI then
			_G.ElvUI[1]:GetModule("Chat"):AddPluginIcons(ElvUISwag)
		end
		RE.Settings = _G.RETabBinderSettings
		_G.LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RETabBinder", RE.AceConfig)
		_G.LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RETabBinder", "RETabBinder")
		RE:OnEvent(self, "ZONE_CHANGED_NEW_AREA")
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "ZONE_CHANGED_NEW_AREA" or (event == "PLAYER_REGEN_ENABLED" and RE.Fail) or event == "DUEL_REQUESTED" or event == "DUEL_FINISHED" or event == "CHAT_MSG_SYSTEM" then
		if event == "CHAT_MSG_SYSTEM" and ... == _G.ERR_DUEL_REQUESTED then
			event = "DUEL_REQUESTED"
		elseif event == "CHAT_MSG_SYSTEM" then
			return
		end

		local BindSet = GetCurrentBindingSet()
		if BindSet ~= 1 and BindSet ~= 2 then
			return
		end
		if InCombatLockdown() then
			RE.Fail = true
			return
		end
		local PVPType = GetZonePVPInfo()
		local _, ZoneType = IsInInstance()

		local TargetKey = GetBindingKey("TARGETNEARESTENEMYPLAYER")
		if TargetKey == nil then
			TargetKey = GetBindingKey("TARGETNEARESTENEMY")
		end
		if TargetKey == nil and RE.Settings.DefaultKey then
			TargetKey = "TAB"
		end

		local LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMYPLAYER")
		if LastTargetKey == nil then
			LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMY")
		end
		if LastTargetKey == nil and RE.Settings.DefaultKey then
			LastTargetKey = "SHIFT-TAB"
		end

		local CurrentBind
		if TargetKey then
			CurrentBind = GetBindingAction(TargetKey)
		end

		if ZoneType == "arena" or PVPType == "combat" or ZoneType == "pvp" or event == "DUEL_REQUESTED" then
			if CurrentBind ~= "TARGETNEARESTENEMYPLAYER" then
				local Success
				if TargetKey == nil then
					Success = true
				else
					Success = SetBinding(TargetKey, "TARGETNEARESTENEMYPLAYER")
				end
				if LastTargetKey then
					SetBinding(LastTargetKey, "TARGETPREVIOUSENEMYPLAYER")
				end
				if Success then
					SaveBindings(BindSet)
					RE.Fail = false
					print("\124cFF74D06C[RETabBinder]\124r PVP Mode")
				else
					RE.Fail = true
				end
			end
		else
			if CurrentBind ~= "TARGETNEARESTENEMY" then
				local Success
				if TargetKey == nil then
					Success = true
				else
					Success = SetBinding(TargetKey, "TARGETNEARESTENEMY")
				end
				if LastTargetKey then
					SetBinding(LastTargetKey, "TARGETPREVIOUSENEMY")
				end
				if Success then
					SaveBindings(BindSet)
					RE.Fail = false
					print("\124cFF74D06C[RETabBinder]\124r PVE Mode")
				else
					RE.Fail = true
				end
			end
		end
	end
end
