--[[ =============== :: Start: More Location Bonuses: Deposits: New Class: TriboEffectDeposit  ============== ]]

local mod_name = "More_Location_Bonuses"
local steam_id = ""
-- local authors = "RustyDios, ChoGGi, SkiRich"
-- local Version = "42+, lol"

local RustyPrint = false
local ModDir = CurrentModPath

local ipTWZIcon_On 		= ModDir .. "/UI/RD_WZ_On.png"
local ipTWZIcon_Locked 	= ModDir .. "/UI/RD_WZ_All.png"
local ipTWZIcon_Off		= ModDir .. "/UI/RD_WZ_Off.png"

--[[ =============== :: Start: Define TriboEffectDeposit  ============== ]]

DefineClass.TriboEffectDeposit = {
	__parents = {
		"EffectDeposit",
		"SkinChangeable",
		"AutoAttachObject",
		"UIAttach",
		"UIRangeBuilding",
		"DoesNotObstructConstruction",
	},

	-- stuff from UIRangeBuilding//Building
	auto_attach_at_init = true,
	UIRange = 5, -- actually required even though I assign it immediately to range_increase ? I mean I figured I could replace all UIRange with range_increase BUT noooo said the lua.gods

	-- stuff from Effect Deposit
	building_class = "Building", 				-- controls the class of building this deposit effects,all buildings
	modifier = false,							-- intialise a modifier to apply to the above
	range_increase = 10,						-- default range
	range_increase_options = {5,8,10,14,18, },	-- options for random range

	resource = "", -- does not need a valid resource type
	city_label = "EffectDeposit",

	--custom infopanel details
	ip_template = "ipEffectDeposit_RD", -- IPDescription borked for default Effect Deposit so I made a non-conditional copy and added TWZ functions
	display_name = "TriboElectric Field",
	ipDescription = "Naturally repulses dust accumulation on outside buildings within the field.\n\nDomes will benefit as long as they are close by, boosted if their center is also within the field. Has no effect on inside Dome Buildings.\n\nCables and Pipe Pylons cannot be built at the field epicenter, however Pipes may cross over and all other buildings have no restrictions.",
	ipTWZState = "On",
	ipTWZIcon = "UI/Icons/bmb_demo.tga",
	display_icon = "UI/Icons/bmb_demo.tga",
	ConstructionStatusName = "TriboDepositNearby",

	entity = "SignDomeBonusTribo",

	--stuff to get fx working correctly
	fx_actor_class = "CrystalShard", -- initially to setup visuals, changed on GameInit
	working = false, -- totally not building though. Needed for Range Rings and FX
	ring = false,
	ring_nextvis = true, -- aids for show/hide the ring post-save game

	-- stuff from triboelectric scrubber
	charge_time = 2 * const.HourDuration,
	dust_clean = 50000,
	charge_thread = false,
	sphere = false,
	cleaning = false,
}
--[[ =============== :: Finish: Define TriboEffectDeposit ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: Init:: ============== ]]

--initialise this deposit and make it unique
function TriboEffectDeposit:Init()

	--deciding the range to affect and by how much
	self.range_increase = table.rand(self.range_increase_options)
	self.modifier = Modifier:new{
		prop = "TriboElectric_Field_Strength",
		amount = self.dust_clean,
		percent = 0,
		id = "TriboElectric Field",
	}

	--configure info panel intial details
	self.ipTWZState = "On"
	self.ipTWZIcon	= ipTWZIcon_On

	--set the UIRange to equal the randomly chosen range_increase
	self.UIRange = self.range_increase

	--[[============== Personal notes for RANGE RINGS forever preserved in this code!!! ==========]]
	--[[this little bastard took me 14 f**king days to fix up..  I called in help from an expert
		-- THANKYOU to ChoGGI for fixing my completely bonkers code with a simple function :) :)
		
		the number is an int expresion of RGB values, the best site I like so far is:: https://www.shodor.org/stella2java/rgbint.html
		my_ring = RangeHexRadius:new()-- bluebase OR RangeHexMultiSelectRadius:new() greybase
		obj:SetColorModifier(6579300)		the object's default colour (RGB(100,100,100))
	--]]
	
	-- reminder that this does NOT need "" around it !, --colour chosen is an electric yellow -- we return it from CreateAndAttachRangeRing
	local ring = self:CreateAndAttachRangeRing(RangeHexMultiSelectRadius,14605846)
	self.ring = ring					--assign the ring to the deposit
	ring.owner = self					--inform the ring it is owned, it's like they got married and will forever be intertwined, the divorce will be messy with all the children
	ring:SetPos(self:GetPos():SetZ(1)) 	-- birth the ring and bring it forth into the world from the mysterious @Off-map location and then bury it into the ground so saving the game doesn't break it

end

-- used to store domes in range
local my_domes = {}

--[[ =============== :: Finish: TriboEffectDeposit :: Init :: ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: GameInit :: ============== ]]

function TriboEffectDeposit:GameInit()
	MapForEach("map", self.building_class, GameInit_ForEachFn, self)

	--booting up the tribo field
	local attaches = self:GetAttaches("TriboelectricScrubberSphere")
	assert(#attaches == 1, "Exactly 1 sphere should be attached to " .. self.class)
	self.sphere = attaches[1]
	self.sphere:SetAttachOffset(0,0,33)
	self.sphere:SetScale(200)
	--self.sphere:SetVisible(false)
	self.sphere:ChangeEntity("Invisible Object") --huzzah all the FX but no balls
	self.sphere.owner = self

	-- setting up flashy visuals
	PlayFX("CrystalCompose",attach,self)
	self.fx_actor_class = "SubsurfaceAnomaly"							-- make it sound/look like any other deposit on selection etc

	self:ForEachAttach("ParSystem",function(a)                         	-- even sneakier, for each flashy visual attached            
		if a:GetParticlesName() == "CrystalCompose" then          		-- check the name for the one I want
			a:SetColorModifier(14605846)                               	-- recolour it to same colour as the range rings
		end
	end)--end par sys for each

	-- refresh working status/set to work
	self.working = true
	self:SetWorking(true)
	self:WorkLightsOn()													-- "power up" the icon.. ffs.. game.. ffs
	self:RefreshNightLightsState()										-- "power up" the icon.. ffs.. game.. ffs
	self:ResetCharging()
end

-- building overides to never adjust SI during day night hours, ugh!
function TriboEffectDeposit:WorkLightsOn()
	self:SetSIModulation(200)
end

function TriboEffectDeposit:WorkLightsOff()
	self:SetSIModulation(200)
end

--[[ =============== :: Finish: TriboEffectDeposit :: GameInit :: ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: Effect Deposit functions :: ============== ]]

--Parent EffectDeposit Overide
function TriboEffectDeposit:CanAffectBuilding(building)
	if building:IsKindOf("Building")then
		return true
	end
end

--`TriboEffectDeposit:AffectBuilding()` will be automatically called once for each building that is placed in range.
function TriboEffectDeposit:AffectBuilding(building)
	if IsValid(building) then
		if building:IsKindOfClasses("Dome", "LowGLab") then
		my_domes[#my_domes +1] = building -- register a dome to be cleaned by this deposit
		end
	end
end

--[[ =============== :: Finish: TriboEffectDeposit :: Effect Deposit functions :: ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: Tribo-Electric Scrubbing :: ============== ]]

-- find and affect all buildings in range
function TriboEffectDeposit:ForEachBuildingInRange(exec, ...)
	MapForEach(self, "hex", self.UIRange, "Building", "DustGridElement", exec, ...)
end

--functions controlling the stop/start/rest times of the scrubber
function TriboEffectDeposit:StopCharging()
	if self.cleaning then
		return
	end

	DeleteThread(self.charge_thread)
	self.charge_thread = false
end

function TriboEffectDeposit:ResetCharging()
	if IsValidThread(self.charge_thread) then
		return
	end

	self.charge_thread = CreateGameTimeThread(function(self)
		while IsValid(self) and self.working do
			Sleep(self.charge_time)
			self:ChargedClean()
		end
		self.charge_thread = false
	end, self)
end

--function doing the actual cleaning of buildings within range AND any stored domes
function TriboEffectDeposit:CleanBuildings()

	--for each building in range
	self:ForEachBuildingInRange(function(building, self)
		if building ~= self then
			if building:IsKindOf("DustGridElement") then
				building:AddDust(-self.dust_clean)
			elseif not building.parent_dome then --outside of dome
				building:AccumulateMaintenancePoints(-self.dust_clean)
				building:DeduceAndReapplyDustVisualsFromState()
			end
			PlayFX("ChargedCleanBuilding", "start", self.sphere, building)
			--RebuildInfoPanel(building) -- added so that warnings vanish on clean
		end
	end, self)

	for i=1, #my_domes do -- if we have registered domes in range of the deposit
		my_domes[i]:AddDust(-self.dust_clean)
		my_domes[i]:AccumulateMaintenancePoints(-self.dust_clean)
		my_domes[i]:DeduceAndReapplyDustVisualsFromState()
		PlayFX("ChargedCleanBuilding", "start", my_domes[i])
	end
end

--play some fxv
function TriboEffectDeposit:ChargedClean()
	PlayFX("ChargedClean", "start", self.sphere)
	PlayFX("TriboelectricScrubberSphere", "start", self.sphere)
	self.cleaning = true
	self.sphere:PlayState("workingStart")
	self:CleanBuildings()
	self.sphere:PlayState("workingIdle", const.eDontCrossfade)
	self.sphere:PlayState("workingEnd")
	self.cleaning = false
	PlayFX("ChargedClean", "end", self.sphere)
	PlayFX("TriboelectricScrubberSphere", "end", self.sphere)
end

--function controlling how long to wait between pulses
function TriboEffectDeposit:GetChargeTime()
	return self.charge_time / const.HourDuration
end

--[[ =============== :: Finish: TriboEffectDeposit :: Tribo-Electric Scrubbing :: ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: OnMsg's :: ============== ]]

-- functions to control FX, not sure what they are actually used for, but was in lua's that deal with Hex Ranges and VFX, so figured it must be important... meh !!
function OnMsg.GatherFXActors(list)
	list[#list + 1] = "TriboEffectDeposit"
end

function OnMsg.GatherFXTargets(list)
	list[#list + 1] = "TriboEffectDeposit"
end

function OnMsg.LoadGame()
	MapForEach("map","TriboEffectDeposit",function (a)
		a.sphere:ChangeEntity("InvisibleObject")
		a:SetSIModulation(200)
	end)
end

--[[ =============== :: Finish: TriboEffectDeposit :: OnMsg's :: ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: Add Skin Systems :: ============== ]]

-- No sense in creating a table each time we select one, giving it some options for now to mimic the rest
local TriboSkins = {"SignDomeBonusTribo","SignDomeBonusTriboOrig"}

-- make the paintbrush show up and cycle skins
function TriboEffectDeposit:GetSkins()
	return TriboSkins
end

--overide for parent Buildings so we don't attach a new sphere on skin change
function TriboEffectDeposit:OnSkinChanged(skin, palette)
	--AutoAttachObjectsToShapeshifter(self) -- removed this function, bascially
end

-- Deep Water/Metals Extraction tech replace the entities by classdef using UpdateEntity
-- this changes our coloured deposits back to the original so we overide the function here
function TriboEffectDeposit:UpdateEntity()
end

--[[ =============== :: Finish: TriboEffectDeposit :: Add Skin Systems :: ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: Range Rings functions :: ============== ]]

-- function to create a new hex range ring and assign it to each deposit
function TriboEffectDeposit:CreateAndAttachRangeRing(ringtype,colour_int)
	local my_ring = ringtype:new()			--create a new ring of the base colour type
	my_ring:SetScale(self.range_increase)	--set the size to the callers range
	my_ring:SetVisible(false)				--hide the ring

	-- change the ring colours
	for i = 1, #my_ring.decals do
		my_ring.decals[i]:SetColorModifier(colour_int)
	end

	return my_ring	--send it back to the caller
end

-- function to control the size of the ring
function TriboEffectDeposit:GetSelectionRadiusScale()
	return self.range_increase
end

-- functions to control the rings on/off during selection, integrated with infopanel TWZ state
local TriboEffectDepositSelected_table = {}

function OnMsg.SelectionAdded(obj, ...)
	if obj:IsKindOf("TriboEffectDeposit") and obj.ipTWZState ~= "Locked" and obj.ipTWZState ~= "Off" then
		obj.ring:SetPos(obj:GetPos():SetTerrainZ()) -- we possibly threw it off map during deselect, so we need to bring it back
		obj.ring:SetVisible(obj.ring_nextvis)
		obj.ring_nextvis = false
	end

	if obj:IsKindOf("TriboEffectDeposit") then -- on, locked or off we still want to add it to the table
		-- add the selected deposit to an external table so we can affect it during de-selection
		TriboEffectDepositSelected_table[#TriboEffectDepositSelected_table+1] = obj
	end
end

function OnMsg.SelectionRemoved(...)
	--if we had an TED selected it'll be in the table
	for i = 1, #TriboEffectDepositSelected_table do
        local obj = TriboEffectDepositSelected_table[i]
				if IsValid(obj) and obj.ipTWZState ~= "Locked" then
					obj.ring:SetVisible(obj.ring_nextvis)
					obj.ring:SetPos(obj:GetPos():SetZ(1))
					obj.ring_nextvis = true
    		end
	end
	table.iclear(TriboEffectDepositSelected_table) --clear our previously selected deposit from memory, should only have one stored this way
end

--[[ =============== :: Finish: TriboEffectDeposit :: Range Rings functions :: ============== ]]

--[[ =============== :: Start: TriboEffectDeposit :: InfoPanel Functions:: ============== ]]

--create the desired display string for other building info panels during building placement within the ConstructionStatus table
ConstructionStatus.TriboDepositNearby = { type = "warning", priority = 95, text = "TriboElectric Field - Dust repulsion will be boosted while within range of effect.", short = "TriboElectric Field" }

-- constructs the infopanel warning for domes in dome range but not tribo's own range :) during construction phase, 
function TriboEffectDeposit:GetConstructionStatusText(building, all_deposits)
	if building:IsKindOfClasses("Dome", "LowGLab") then
		return TriboDepositNearby
	else
		return ""
	end
end

--insert code to update construction status's... now complete in additional file :) during construction phase,
--[[
	function Building:IsClosetoTribo()
	see included overide function
]]

--create the desired displays for our custom info panel effects section
function TriboEffectDeposit:GetInfopanelDetails()
	local stringIP = "Field Range<right>" .. self.range_increase .. " Hexes<left>\nField Strength<right>".. self.dust_clean * 0.001 .. " %"
	return stringIP
end

-- infopanel icons locations/filenames, set to ipTWZIcon_On in Init .	.. Toggle Work Zones idea/images and help from SkiRich
--[[
	moved to the top so the assets load before the infopanel is called in the class define
]]

-- infopanel logic code to interact with selected obj code .			.. Toggle Work Zones idea/images and help from SkiRich
function TriboEffectDeposit:infopanel_TWZ()
	if self.ipTWZState == "On" then 									--default individual toggles...if on cycle to Locked
		self.ring:SetVisible(true)
		self.ipTWZIcon = ipTWZIcon_Locked
		self.ipTWZState = "Locked"
	elseif self.ipTWZState == "Locked" then 							--don't hide on deselection ... if locked cycle to off
		self.ipTWZIcon = ipTWZIcon_Off
		self.ipTWZState ="Off"
		self.ring:SetVisible(false)
	elseif self.ipTWZState == "Off" then 								--don't show on select .. if off cycle to on
		self.ring:SetVisible(true)
		self.ring:SetPos(self:GetPos():SetTerrainZ())
		self.ring_nextvis = false
		self.ipTWZIcon = ipTWZIcon_On
		self.ipTWZState = "On"
	end
end

--[[ =============== :: Finish: TriboEffectDeposit :: InfoPanel Functions:: ============== ]]

--[[ =============== :: Finish: More Dome Bonus Deposits:New Class :: TriboEffectDeposit ============== ]]