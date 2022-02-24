include('shared.lua')

function SWEP:Think()

end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:DrawWorldModel()
	self:DrawWorldModelTranslucent()
end

function SWEP:Holster()
	self.Owner:stopSounds()
	if self.Owner.rightHilt then
		self.Owner.rightHilt:SetNoDraw(true)
		self.Owner.leftHilt:SetNoDraw(true)
	end
end

function SWEP:Deploy()

end