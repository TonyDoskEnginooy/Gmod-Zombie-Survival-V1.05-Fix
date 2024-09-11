if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Boom Stick"
	SWEP.Author = "JetBoom"
    SWEP.ViewModelFOV = 75
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	killicon.AddFont("weapon_zs_boomstick", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base = "weapon_zs_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

SWEP.Weight = 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ReloadDelay = 3.0

SWEP.Primary.Sound = "weapons/shotgun/shotgun_dbl_fire.wav"
SWEP.Primary.Recoil = 12.5
SWEP.Primary.Damage = 36
SWEP.Primary.NumShots = 12
SWEP.Primary.Cone = 0.17
SWEP.Primary.ClipSize = 1
SWEP.Primary.Delay = 1.5
SWEP.Primary.DefaultClip = 24
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.ReloadDelay)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if not self:CanPrimaryAttack() then return end

	self.Weapon:EmitSound(self.Primary.Sound)
	self:ZSShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
	self:TakePrimaryAmmo(1)
	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))

	if CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end
