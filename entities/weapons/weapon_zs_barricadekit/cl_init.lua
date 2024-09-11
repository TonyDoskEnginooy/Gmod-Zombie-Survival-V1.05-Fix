include("shared.lua")

SWEP.PrintName = "'Aegis' Barricade Kit"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false
SWEP.HoldType = "rpg"

SWEP.Slot = 4
SWEP.SlotPos = 5

CreateClientConVar("zs_barricadekityaw", 0, false, true)

function SWEP:Initialize()
	self:SetDeploySpeed(1.1)
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:GetViewModelPosition(pos, ang)
	if self.Owner:GetNetworkedBool("IsHolding") then
		return pos + ang:Forward() * -256, ang
	end

	return pos, ang
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
	RunConsoleCommand("zs_barricadekityaw", math.NormalizeAngle(GetConVarNumber("zs_barricadekityaw") + 10))
end

function SWEP:CanSecondaryAttack()
	return true
end

function SWEP:Think()
	if 0 < self:Clip1() then
		local owner = self.Owner
		local effectdata = EffectData()
			effectdata:SetOrigin(owner:GetShootPos() + owner:GetAimVector() * 50)
			effectdata:SetNormal(owner:GetAimVector())
		util.Effect("barricadeghost", effectdata, false, true)
	end
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "HUDFontSmall", x + wide/2, y + tall/2, COLOR_RED, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.PrintName, "HUDFontSmall", XNameBlur2 + x + wide/2, YNameBlur + y + tall/2, color_blur1, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.PrintName, "HUDFontSmall", XNameBlur + x + wide/2, YNameBlur + y + tall/2, color_blu1, TEXT_ALIGN_CENTER)
end
