AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.Deployed = false

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	self.Owner:DrawWorldModel(false)

	if self.Deployed then return end
	self.Deployed = true

	local effectdata = EffectData()
		effectdata:SetEntity(self.Owner)
	util.Effect("chemzombieambient", effectdata)
end

SWEP.NextWalk = CurTime()
SWEP.NextIdle = CurTime()

function SWEP:Think()
	if self.Owner:GetVelocity():Length() <= 0 then
		self.NextWalk = CurTime()
		if self.NextIdle <= CurTime() then 
			self.Owner:DoAnimationEvent(ACT_IDLE)
			self.NextIdle = CurTime() + 2.9
		end
	else
		self.NextIdle = CurTime()
		if self.NextWalk <= CurTime() then 
			self.Owner:DoAnimationEvent(ACT_WALK)
			self.NextWalk = CurTime() + 0.98
		end
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	return false
end
