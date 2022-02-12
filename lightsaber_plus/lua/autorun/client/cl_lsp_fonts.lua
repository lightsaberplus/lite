surface.CreateFont( "xozziesNoodle", {
	font = "Arial",
	size = ScreenScale(8),
	weight = 50,
	antialias = true,
})

surface.CreateFont( "xozziesNoodle2", {
	font = "Arial",
	size = ScreenScale(8),
	weight = 4500,
	antialias = true,
})

surface.CreateFont( "cooldude", {
	font = "Arial",
	size = ScreenScale(5),
	weight = 4500,
	antialias = true,
})

surface.CreateFont( "hash", {
	font = "Arial",
	size = ScreenScale(4),
	weight = 45,
	antialias = true,
})


surface.CreateFont( "form", {
	font = "Arial",
	size = 90,
	weight = 45,
	antialias = true,
})


surface.CreateFont( "weebs", {
	font = LIGHTSABER_PLUS_HUD_HIT_NUMBERS_FONT or "Vecna",
	size = ScreenScale(LIGHTSABER_PLUS_HUD_HIT_NUMBERS_SIZE or 15),
	weight = LIGHTSABER_PLUS_HUD_HIT_NUMBERS_THICC or 45,
	antialias = true,
})


net.Receive("void-text", function()
	local pack = net.ReadTable()
	chat.AddText(Color(255,0,255), "Lightsaber+  ",unpack(pack))
	MsgC("\n")
end)

net.Receive("void-logs", function()
	local pack = net.ReadTable()
	MsgC(Color(255,0,255), "Lightsaber+ ",unpack(pack))
	MsgC("\n")
end)