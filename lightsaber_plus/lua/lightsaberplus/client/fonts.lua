surface.CreateFont( "xozziesNoodle", {
	font = "LightSaberPlusBold",
	size = ScreenScale(8),
	weight = 50,
	antialias = true,
})

surface.CreateFont( "xozziesNoodle2", {
	font = "LightSaberPlusBold",
	size = ScreenScale(8),
	weight = 4500,
	antialias = true,
})

surface.CreateFont( "cooldude", {
	font = "LightSaberPlusBold",
	size = ScreenScale(5),
	weight = 4500,
	antialias = true,
})

surface.CreateFont( "hash", {
	font = "LightSaberPlusBold",
	size = ScreenScale(4),
	weight = 45,
	antialias = true,
})


surface.CreateFont( "form", {
	font = "LightSaberPlusBold",
	size = 90,
	weight = 45,
	antialias = true,
})


surface.CreateFont( "weebs", {
	font = LSP.Config.HUDHitFontName or "Vecna",
	size = ScreenScale(LSP.Config.HUDHitNumberSize or 15),
	weight = LSP.Config.HUDHitFontThickNess or 45,
	antialias = true,
})


net.Receive("ls++-text", function()
	local pack = net.ReadCompressedTable()
	chat.AddText(Color(255,0,255), "Lightsaber+  ",unpack(pack))
	MsgC("\n")
end)

net.Receive("ls++-logs", function()
	local pack = net.ReadCompressedTable()
	MsgC(Color(255,0,255), "Lightsaber+ ",unpack(pack))
	MsgC("\n")
end)