/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2017 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "Star Wars Vehicles SNPCs"
local AddonName = "Star Wars Vehicles"
local AddonType = "SNPC"
local AutorunFile = "autorun/vj_swveh_spawn.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')
		
	local vCat = "Star Wars"
	VJ.AddNPC("AT-ST","npc_vj_sw_atst",vCat)
	VJ.AddNPC("AT-AT","npc_vj_sw_atat",vCat)
	VJ.AddNPC("AT-TE","npc_vj_sw_atte",vCat)
	VJ.AddNPC("FO AT-ST","npc_vj_sw_atst_fo",vCat)
	VJ.AddNPC("FO AT-AT","npc_vj_sw_atat_fo",vCat)
	VJ.AddNPC("AV7 Cannon","npc_vj_sw_av7",vCat)

	-- Precache Particles -------------------------------------------------------------------------------------------------------------------------
	game.AddParticles("particles/flood.pcf")
-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("ERROR!")
				VJF:SetSize(790,560)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end
				
				local VJURL = vgui.Create("DHTML",VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				VJURL:Dock(FILL)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end