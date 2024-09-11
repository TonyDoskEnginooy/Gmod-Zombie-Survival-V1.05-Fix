include("shared.lua")

SWEP.PrintName = "Zombie"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

--[[
function SWEP:Think()
	if CurTime() >= self.NextYell then 
		if self.Owner:GetVelocity():Length() <= 0 then
			self.NextWalk = CurTime()
			if self.NextIdle <= CurTime() then 
				self.Owner:DoAnimationEvent(ACT_IDLE)
				self.NextIdle = CurTime() + 0.9
			end
		else
			if CurTime() >= self.NextSwing + 0.25 and self.NextWalk <= CurTime() then 
				self.Owner:DoAnimationEvent(ACT_WALK)
				self.NextWalk = CurTime() + 2
			end
		end
	else
		if self.Owner:GetVelocity():Length() <= 0 then
			self.NextFireWalk = CurTime()
			if self.NextFireIdle <= CurTime() then 
				self.Owner:DoAnimationEvent(ACT_IDLE_ON_FIRE)
				self.NextFireIdle = CurTime() + 0.9
			end
		else
			if CurTime() >= self.NextSwing + 0.25 and self.NextFireWalk <= CurTime() then 
				self.Owner:DoAnimationEvent(ACT_WALK_ON_FIRE)
				self.NextFireWalk = CurTime() + 0.9
			end
		end
	end
end
]]

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "HUDFontSmall", x + wide/2, y + tall/2, COLOR_RED, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.PrintName, "HUDFontSmall", XNameBlur2 + x + wide/2, YNameBlur + y + tall/2, color_blur1, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.PrintName, "HUDFontSmall", XNameBlur + x + wide/2, YNameBlur + y + tall/2, color_blu1, TEXT_ALIGN_CENTER)
end
