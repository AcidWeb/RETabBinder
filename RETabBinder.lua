SLASH_RETABBINDER1, SLASH_RETABBINDER2 = "/rtb", "/retabbinder";

function RETabBinder_OnLoad(self)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("DUEL_REQUESTED");
	self:RegisterEvent("DUEL_FINISHED");
	self:RegisterEvent("CHAT_MSG_SYSTEM");
	self:RegisterEvent("ADDON_LOADED");

	RTB_Fail = false
end

function SlashCmdList.RETABBINDER(msg)
	if msg == "" then
		print("\124cFF74D06C[RETabBinder]\124r");
		print("/rtb default - Toggle default keybinds.")
	elseif msg == "default" then 
		if RTB_DefaultKey == true then
			RTB_DefaultKey = false;
			print("\124cFF74D06C[RETabBinder]\124r Default keybinds disabled.");
		else 
			RTB_DefaultKey = true;
			print("\124cFF74D06C[RETabBinder]\124r Default keybinds enabled.");
		end
	end
end

function RETabBinder_OnEvent(event,...)
	if event == "ADDON_LOADED" then
		if RTB_DefaultKey == nil then
			RTB_DefaultKey = true;
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		local RTBChatMessage = ...;
		if RTBChatMessage == ERR_DUEL_REQUESTED then
			event = "DUEL_REQUESTED"
		end
	elseif event=="ZONE_CHANGED_NEW_AREA" or (event=="PLAYER_REGEN_ENABLED" and RTB_Fail) or event=="DUEL_REQUESTED" or event=="DUEL_FINISHED" then
		local RTB_BindSet = GetCurrentBindingSet();
		local RTB_PVPType = GetZonePVPInfo();
		local _, RTB_ZoneType = IsInInstance();

		RTB_TargetKey = GetBindingKey("TARGETNEARESTENEMYPLAYER");
		if RTB_TargetKey == nil then
			RTB_TargetKey = GetBindingKey("TARGETNEARESTENEMY");
		end
		if RTB_TargetKey == nil and RTB_DefaultKey == true then
			RTB_TargetKey = "TAB"
		end

		RTB_LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMYPLAYER");
		if RTB_LastTargetKey == nil then
			RTB_LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMY");
		end
		if RTB_LastTargetKey == nil and RTB_DefaultKey == true then
			RTB_LastTargetKey = "SHIFT-TAB"
		end

		if RTB_TargetKey ~= nil then
			RTB_CurrentBind = GetBindingAction(RTB_TargetKey);
		end

		if RTB_ZoneType == "arena" or RTB_PVPType == "combat" or RTB_ZoneType == "pvp" or event=="DUEL_REQUESTED" then
			if RTB_CurrentBind ~= "TARGETNEARESTENEMYPLAYER" then
				if RTB_TargetKey == nil then
					RTB_Success = 1;
				else 
					RTB_Success = SetBinding(RTB_TargetKey,"TARGETNEARESTENEMYPLAYER");
				end
				if RTB_LastTargetKey ~= nil then
					SetBinding(RTB_LastTargetKey,"TARGETPREVIOUSENEMYPLAYER");
				end
				if RTB_Success == 1 then
					SaveBindings(RTB_BindSet);
					RTB_Fail = false;
					print("\124cFF74D06C[RETabBinder]\124r PVP Mode");
				else
					RTB_Fail = true
				end
			end
		else
			if RTB_CurrentBind ~= "TARGETNEARESTENEMY" then
				if RTB_TargetKey == nil then
					RTB_Success = 1;
				else
					RTB_Success = SetBinding(RTB_TargetKey,"TARGETNEARESTENEMY");
				end
				if RTB_LastTargetKey ~= nil then
					SetBinding(RTB_LastTargetKey,"TARGETPREVIOUSENEMY");
				end
				if RTB_Success == 1 then
					SaveBindings(RTB_BindSet);
					RTB_Fail = false;
					print("\124cFF74D06C[RETabBinder]\124r PVE Mode");
				else
					RTB_Fail = true
				end
			end
		end
	end
end
