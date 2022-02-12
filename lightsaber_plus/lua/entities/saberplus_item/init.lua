AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	--self.Entity:SetModel("models/props_combine/combine_mine01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.spawnTime = CurTime() + 120
	self:GetPhysicsObject():Wake()
end

function ENT:Use(ply)
	ply:giveItem(self.itemClass, self.itemHash)
	self:EmitSound("items/battery_pickup.wav")
	self:Remove()
end

function ENT:Think()
	if !(self.itemClass) then
		self:Remove()
	end
	if self.spawnTime <= CurTime() then
		self:Remove()
	end
end

















