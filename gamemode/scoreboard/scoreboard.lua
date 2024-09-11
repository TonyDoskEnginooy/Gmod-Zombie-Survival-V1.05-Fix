-- Copying this scoreboard means you're a huge, gigantic fucking faggot and you should kill youself for being so.

local texGradient = surface.GetTextureID("gui/center_gradient")
local matDefaultAward = surface.GetTextureID("noxiousawards/default")

local PANEL = {}
local AwardIcons = {}

function PANEL:Init()
	surface.CreateFont( "noxnetbig", {
		font = "Tahoma", --Frosty not working.
		extended = false,
		size = 32,
		weight = 200,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
	surface.CreateFont( "noxnetnormal", {
		font = "akbar",
		extended = false,
		size = 24,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
	SCOREBOARD = self
	self.Mode = 1
	self.Modes = {"Players", "Classes", "Help"}
	self.ClassButtons = {}
	self.Buttons = {}
	self.ViewPlayer = Entity(0)
	self.HoldingPlayer = Entity(0)
	self.HoldingTime = 0
	for i=1, 3 do
		self.Buttons[i] = {}
	end
end

local buttonStop = false
local zbuttonStop = false
local button
local zbutton = {}

function PANEL:Paint()
	local wide, tall = self:GetWide(), self:GetTall()
	draw.RoundedBox(16, 0, 0, wide, tall, color_black)

	if not buttonStop then
		for i=1, 3 do
			button = vgui.Create("ScoreboardTab", self)
			button.Mode = i
			button.Text = self.Modes[i]
			button:SetPos(wide * 0.93, tall * 0.05 + i * tall * 0.04)
			button:SetSize(wide * 0.07, tall * 0.04)
			if i == 3 then
				buttonStop = true
			end
		end
	end

	for i=1, #ZombieClasses do 
		if IsValid(zbutton[i]) then
			zbutton[i]:SetPos(wide * 10000, tall * 10000)
		end
	end

	draw.SimpleText("-nVts-Zombie Survival v1.05 - nvts.online/discord", "noxnetbig", wide * 0.5, tall * 0.01, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 50)
	surface.DrawTexturedRect(0, 0, wide, tall)

	if self.Mode == 1 then
		local y = tall * 0.1
		local x = wide * 0.1
		local x2 = x + wide * 0.4
		local x3 = x + wide * 0.7

		local PlayerSorted = {}
		for _, pl in pairs(player.GetAll()) do
			if pl:Team() == TEAM_HUMAN then
				table.insert(PlayerSorted, pl)
			end
		end

		table.sort(PlayerSorted, function (a, b) return a:Frags() > b:Frags() end)

		local PlayerSorted2 = {}
		for _, pl in pairs(player.GetAll()) do
			if pl:Team() == TEAM_UNDEAD then
				table.insert(PlayerSorted2, pl)
			end
		end

		table.sort(PlayerSorted2, function (a, b) return a:Frags() > b:Frags() end)

		PlayerSorted = table.Add(PlayerSorted, PlayerSorted2)

		if #PlayerSorted > 38 then
			for i=39, #PlayerSorted - 39 do
				table.remove(PlayerSorted, 39)
			end
		end

		draw.SimpleText("Name", "Default", x, y, color_white, TEXT_ALIGN_LEFT)
		draw.SimpleText("Ping", "Default", x3, y, color_white, TEXT_ALIGN_CENTER)
		local yadding = tall * 0.02
		y = y + yadding
		surface.DrawLine(0, y, wide, y)
		y = y + yadding
		for i, pl in pairs(PlayerSorted) do
			local colortouse = team.GetColor(pl:Team())
			--[[if gui.MouseX() < w * 0.4 and gui.MouseX() > w * 0.2 then
				local mousey = gui.MouseY() - h*0.032
				if mousey < y + w*0.004 and mousey > y - w*0.004 then
					local stt = "Opening profile"
					for yy=1, math.random(2, 4) do
						stt = stt.."."
					end
					draw.SimpleText(stt, "DefaultBold", gui.MouseX() - self.PosX + 24, gui.MouseY() - self.PosY, COLOR_RED, TEXT_ALIGN_LEFT)
					colortouse = color_white
					if self.HoldingPlayer ~= pl then
						self.HoldingPlayer = pl
						self.HoldingTime = 0
					end
					self.HoldingTime = self.HoldingTime + FrameTime()
					if self.HoldingTime > 1.1 then
						self:SetMode(714)
						self.ViewPlayer = pl
						surface.PlaySound("buttons/button4.wav")
						self.HoldingPlayer = Entity(0)
						self.HoldingTime = 0
					end
				end
			end]]
			draw.SimpleText(pl:Name(), "Default", x, y, colortouse, TEXT_ALIGN_LEFT)
			draw.SimpleText(pl:Frags().." / "..pl:Deaths(), "Default", x2, y, colortouse, TEXT_ALIGN_CENTER)
			draw.SimpleText(pl:Ping(), "Default", x3, y, colortouse, TEXT_ALIGN_CENTER)
			y = y + yadding
		end
	elseif self.Mode == 2 then
		local y = tall * 0.1
		local x = wide * 0.1
		local x22 = wide * 0.15
		local x2 = x + wide * 0.4
		local buttonx1 = wide * 0.02
		local buttony = tall * 0.08 + tall * 1 * 0.06 - 50

		if not zbuttonStop then 
			for i=1, #ZombieClasses do
				local x = 1
				if not ZombieClasses[i].Hidden then
					zbutton[i] = vgui.Create("ClassButton", self)
					zbutton[i].Class = i
					zbutton[i]:SetSize(wide * 0.05, wide * 0.05)
					table.insert(self.Buttons[self.Mode], zbutton[i])
					x = x + 1
				end
				if i == #ZombieClasses then
					zbuttonStop = true
				end
			end
		end

		for i=1, #ZombieClasses do 
			if IsValid(zbutton[i]) then
				zbutton[i]:SetPos(buttonx1, buttony + i*80)
			end
		end

		draw.SimpleText("Class Name", "Default", x, y, color_white, TEXT_ALIGN_LEFT)
		draw.SimpleText("Threshold", "Default", x2, y, color_white, TEXT_ALIGN_CENTER)
		local yadding = tall * 0.02
		y = y + yadding
		surface.DrawLine(0, y, wide, y)
		y = y + yadding

		for i=1, #ZombieClasses do
			if not ZombieClasses[i].Hidden then
				local colortouse = Color(255, 0, 0, 255)
				local canuse = false
				if INFLICTION >= ZombieClasses[i].Threshold then
					colortouse = Color(0, 255, 0)
					canuse = true
				end
				draw.SimpleText(ZombieClasses[i].Name, "Default", x, y, colortouse, TEXT_ALIGN_LEFT)
				draw.SimpleText("%"..math.ceil(ZombieClasses[i].Threshold * 100), "DefaultSmall", x2, y, colortouse, TEXT_ALIGN_CENTER)
				local strexp = string.Explode("@", ZombieClasses[i].Description)
				for x=1, #strexp do
					draw.SimpleText(strexp[x], "DefaultSmall", x22, y + x * tall * 0.02, colortouse, TEXT_ALIGN_LEFT)
				end
				y = y + tall * 0.06
			end
		end
		local xysize = wide * 0.05
		y = tall * 0.9
		draw.RoundedBox(8, wide*0.225, y, xysize, xysize, Color(0, 255, 0))
		draw.SimpleText("Can switch to", "DefaultSmall", wide*0.25, y + xysize, color_white, TEXT_ALIGN_CENTER)

		draw.RoundedBox(8, wide*0.475, y, xysize, xysize, Color(255, 0, 0))
		draw.SimpleText("Not enough infliction", "DefaultSmall", wide*0.5, y + xysize, color_white, TEXT_ALIGN_CENTER)

		draw.RoundedBox(8, wide*0.725, y, xysize, xysize, color_white)
		draw.SimpleText("Switch to this class", "DefaultSmall", wide*0.75, y + xysize, color_white, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(table.ToString(HELP_TEXT, "", true), "noxnetnormal", wide * 0.5, tall * 0.5, Color(255, 0, 0), TEXT_ALIGN_CENTER)
	end
end

function PANEL:PerformLayout()
	local wide, tall = self:GetWide(), self:GetTall()
	self:SetSize(640, h * 0.95)
	self.PosX = (w - wide) * 0.5
	self.PosY = (h - tall) *0.5
	self:SetPos(self.PosX, self.PosY)
end

function PANEL:SetMode(changemode)
	self.Mode = changemode
end
vgui.Register("ScoreBoard", PANEL, "Panel")

PANEL = {}
function PANEL:DoClick()
	local MySelf = LocalPlayer()
	local MyTeam = MySelf:Team()
	if self:GetParent().Mode == self.Mode then return end
	local rememberMode = self:GetParent().Mode
	self:GetParent().Mode = button.Mode + (self.Mode - 3)
	if self:GetParent().Mode == 2 and MyTeam == TEAM_HUMAN then
		self:GetParent().Mode = rememberMode
	else
		surface.PlaySound("buttons/lever8.wav")
	end
end
function PANEL:Paint()
	local wide, tall = self:GetWide(), self:GetTall()
	local bgColor = Color(120, 120, 120, 100)
	local fgColor = Color(255, 255, 255, 100)

	draw.SimpleText(self.Text, "Default", wide / 2, tall / 2, fgColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return true
end
vgui.Register( "ScoreboardTab", PANEL, "Button" )


PANEL = {}
function PANEL:DoClick()
	local MySelf = LocalPlayer()
	if INFLICTION < ZombieClasses[self.Class].Threshold or MySelf:Team() ~= TEAM_UNDEAD then return end
	MySelf:ConCommand("zs_class "..ZombieClasses[self.Class].Name.."\n")
	surface.PlaySound("buttons/button1.wav")
end
function PANEL:Paint()
	local wide, tall = self:GetWide(), self:GetTall()
	local bgColor = Color(255, 0, 0, 200)
	if INFLICTION >= ZombieClasses[self.Class].Threshold then
		bgColor = Color(0, 255, 0, 200)
		if self.Selected or self.Armed then
			bgColor = color_white
		end
	end
	draw.RoundedBox(8, 0, 0, wide, tall, bgColor)
	return true
end
vgui.Register("ClassButton", PANEL, "Button")
