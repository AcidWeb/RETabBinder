function RETabBinder_OnLoad(self)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("DUEL_REQUESTED");
	self:RegisterEvent("DUEL_FINISHED");
	self:RegisterEvent("CHAT_MSG_SYSTEM");
	TB_Fail = false
end

function RETabBinder_OnEvent(event,...)
	if event=="CHAT_MSG_SYSTEM" then
		if arg1==ERR_DUEL_REQUESTED then
			event = "DUEL_REQUESTED"
		end
	end

	if event=="ZONE_CHANGED_NEW_AREA" or (event=="PLAYER_REGEN_ENABLED" and TB_Fail) or event=="DUEL_REQUESTED" or event=="DUEL_FINISHED" then
		local which = GetCurrentBindingSet();
		local pvpType = GetZonePVPInfo();
		local _, zoneType = IsInInstance();

		TB_TargetKey = GetBindingKey("TARGETNEARESTENEMYPLAYER");
		if TB_TargetKey == nil then
			TB_TargetKey = GetBindingKey("TARGETNEARESTENEMY");
		end
		if TB_TargetKey == nil then
			TB_TargetKey = "TAB"
		end
		
		TB_LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMYPLAYER");
		if TB_LastTargetKey == nil then
			TB_LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMY");
		end
		if TB_LastTargetKey == nil then
			TB_LastTargetKey = "SHIFT-TAB"
		end
		
		local CurrentBind = GetBindingAction(TB_TargetKey);
		if zoneType == "arena" or pvpType == "combat" or zoneType == "pvp" or event=="DUEL_REQUESTED" then
			if CurrentBind ~= "TARGETNEARESTENEMYPLAYER" then
				local success = SetBinding(TB_TargetKey,"TARGETNEARESTENEMYPLAYER");
				SetBinding(TB_LastTargetKey,"TARGETPREVIOUSENEMYPLAYER");
				if success == 1 then
					SaveBindings(which);
					TB_Fail = false
				else
					TB_Fail = true
				end
			end
		else
			if CurrentBind ~= "TARGETNEARESTENEMY" then
				local success = SetBinding(TB_TargetKey,"TARGETNEARESTENEMY");
				SetBinding(TB_LastTargetKey,"TARGETPREVIOUSENEMY");
				if success == 1 then
					SaveBindings(which);
					TB_Fail = false
				else
					TB_Fail = true
				end
			end
		end
	end
end
