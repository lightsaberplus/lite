local meta = FindMetaTable("Player")

function meta:stopSounds()
	self.sounds = self.sounds or {}
	for k,v in pairs(self.sounds) do
		v:Stop()
	end
	self.sounds = {}
end

net.Receive("saberplus-stop-saber-sound", function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		ply:stopSounds()
	end
end)

net.Receive("saberplus-saber-sound", function()
	local f = net.ReadFloat()
	LocalPlayer().active = CurTime() + f
end)

function doSounds(ply, name, pos)
	if LIGHTSABER_PLUS_KILL_SOUNDS then return end
	ply.sounds = ply.sounds or 	{}
	if !(ply.sounds[name]) then
		ply.sounds[name] = CreateSound(ply, "lightsaber/saber_loop8.wav")
		ply.sounds[name]:Play()
	end
	if ply.sounds[name] then
		local speed = pos:Distance(ply.blades[name].pos)
		ply.sounds[name]:ChangeVolume(math.Clamp(0.25 + math.abs(speed/7),0,1))
		ply.sounds[name]:ChangePitch(100 + speed/4)
	end
	
	if !(ply.sounds[name.."hup"]) then
		ply.sounds[name.."hup"] = CreateSound(ply, "hfg/weapons/saber/saberhup1.mp3")
		ply.sounds[name.."hup"]:Play()
		ply.sounds[name.."hup"]:ChangeVolume(0)
	end
	if ply.sounds[name.."hup"] then
		local speed = pos:Distance(ply.blades[name].pos)
		ply.sounds[name.."hup"]:ChangeVolume(math.Clamp( math.abs(speed/7),0,1))
	end
end

