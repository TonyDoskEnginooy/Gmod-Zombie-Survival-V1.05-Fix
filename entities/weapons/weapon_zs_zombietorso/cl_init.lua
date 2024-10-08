include("shared.lua")

SWEP.PrintName = "Zombie Torso"
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

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "HUDFontSmall", x + wide/2, y + tall/2, COLOR_RED, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.PrintName, "HUDFontSmall", XNameBlur2 + x + wide/2, YNameBlur + y + tall/2, color_blur1, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.PrintName, "HUDFontSmall", XNameBlur + x + wide/2, YNameBlur + y + tall/2, color_blu1, TEXT_ALIGN_CENTER)
end

function SWEP:CalcViewModelView(ViewModel, oldPos, oldAng, pos, ang)
    local newPos = pos + Vector(0, 0, -35)
    local newAng = ang

    return newPos, newAng
end
