local saberplusVersion = "0.4.15"
local lastVersionCheck = 0
local lastMessage = 0
local bustedVersion = "VAR_UNSET_BIGBOY_ERROR"
local outdated = false

function checkForLightsaberPlusUpdates()
	http.Fetch("https://lightsaber.plus/log/premium",function(b,l,h,c)
		if saberplusVersion != b then
			outdated = true
			bustedVersion = b
		end
	end,function() end)
end

hook.Add("Think", "29-40kopd;fg-4", function()
	if lastVersionCheck <= CurTime() then
		checkForLightsaberPlusUpdates()
		lastVersionCheck = CurTime() + 3600 -- check every hour
	end
	if outdated then
		if lastMessage <= CurTime() then
			for k,v in pairs(player.GetAll()) do
				if v:IsAdmin() then
					v:text({Color(255,25,255), "Light",  Color(0,100,255),"saber", Color(255,255,255), "+ ", Color(255,0,0), "Outdated Version Detected: v", Color(255,255,0), saberplusVersion, Color(255,0,0), " Please upgrade to: v", Color(255,255,0), bustedVersion})
				end
			end
			lastMessage = CurTime() + 60
		end
	end
	
end)
