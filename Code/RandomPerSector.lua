--[[ =========== Start:: More Location Bonuses : Random Spawn Per Sector Script:  ========== --]]

local mod_name = "More_Location_Bonuses"
local steam_id = ""
-- local authors = "RustyDios, Aerwidh"
-- local Version = "1"

local RustyPrint = false
local city = UICity

--[[ =========== Start:: Function to return a random Sequence Action  ========== --]]

local function RD_GetRandomAnomalySequence()
    local Seq = table.rand{
		--Sequence Title                  Effects   -- all anomalies grant a default 1,000 - 1,250 - 1,500 research points on scan
		"Rare Resource - Sulphides",     --tech boost Engineering 10% OR 1000 research points
		"Rare Resource - Chromium",      --tech boost Engineering 10% OR Deep PreciousMetals Deposit (High, 700000)
		"Rare Resource - Beryllium",     --tech boost Physics 10%
		"Rare Resource - Tellurium",     --tech boost Robotics 10%
		"Rare Resource - Germanium",     --PreciousMetals Deposit (Very High, 1000000)
		"Rare Resource - Iridium",       --tech boost Physics 10%
		"Underground Cavity",            --Metals Deposit (Very High, 1000000)
		"Ice XV",                        --funding reward 500000000 (.5B)
		"Curiosity",                     --tech boost Social 10% OR funding reward 500000000 (.5B)
		"Beagle 2 Found",                --tech boost Robotics 10%
		"Phobos 2 Crash Site",           --3 extra anomilies (Ice XV, Underground Cavity, Iridium)
		"Dust Devil",                    --spawn dust devil 50% probability
		"Natural Gas Pocket",            --tech boost Physics 10% OR Engineering 10% OR funding reward 500000000 (.5B)
		"Radiation Pocket",              --Metals Deposit (Very High, 1024000) OR PreciousMetals (Very High, 300000)
		"Static Dust Charge",            --2000 research points
		"Electromagnetic Concentration", --Rover Malfunction, Techs boosts 50% (LowGDrive, AutonomousSensors), funding reward 200000000 (.2B)
		"Magnesium Sulphates",           --tech boost Robotics 10%
		"Asteroid Impact Site",          --funding reward 800000000 (.8B), 3000 research points
		"Atypic Debris",                 --1x Genius Scientist
		"Rare metals in meteor",         --ResourceStockpile of 30 Precious Metals
		"Crust Fault",                   --Rover Malfunctions
		"Past Life on Mars",             --funding reward 500000000 (.5B) OR 50 extra applicants
		"Natural Beauty",                --50 extra applicants
		"Scientific Find",               --funding reward 200000000 (.2B), OR 2x DroneHub Prefab OR 4x MoistureVaporator Prefab
		"Geological Composition",        --Water Deposit (Very High Grade, 20000000)
		"Stuning Vista",                 --1x Celebrity Applicant  and Vista EffectDeposit
		"Alien Artifact",                --funding reward 400000000 (.m4B)
		"Nothing",                       --nothing happens
    }
   return Seq
end
--[[ =========== Finish:: Function to return a random Sequence Action  ========== --]]

--[[ =========== Start:: Function to return a random Breakthrough  ========== --]]

local function RD_GetRandomBreakthroughTech()
	local bt = table.rand{
		"ConstructionNanites",
		"HullPolarization",
		"ProjectPhoenix",
		"SoylentGreen",
		"NeuralEmpathy",
		"RapidSleep",
		"ThePositronicBrain",
		"SafeMode",
		"HiveMind",
		"SpaceRehabilitation",
		"WirelessPower",
		"PrintedElectronics",
		"CoreMetals",
		"CoreWater",
		"CoreRareMetals",
		"SuperiorCables",
		"SuperiorPipes",
		"AlienImprints",
		"NocturnalAdaptation",
		"GeneSelection",
		"MartianDiet",
		"EternalFusion",
		"SuperconductingComputing",
		"NanoRefinement",
		"ArtificialMuscles",
		"InspiringArchitecture",
		"GiantCrops",
		"NeoConcrete",
		"AdvancedDroneDrive",
		"DryFarming",
		"MartianSteel",
		"VectorPump",
		"Superfungus",
		"HypersensitivePhotovoltaics",
		"FrictionlessComposites",
		"ZeroSpaceComputing",
		"MultispiralArchitecture",
		"MagneticExtraction",
		"SustainedWorkload",
		"ForeverYoung",
		"MartianbornIngenuity",
		"CryoSleep",
		"Cloning",
		"GoodVibrations",
		"DomeStreamlining",
		"PrefabCompression",
		"ExtractorAI",
		"ServiceBots",
		"OverchargeAmplification",
		"PlutoniumSynthesis",
		"InterplanetaryLearning",
		"Vocation-Oriented Society",
		"PlasmaRocket",
		"AutonomousHubs",
		"FactoryAutomation",
		"GemArchitecture",
	}
	--UICity:SetTechDiscovered(bt) -- set if the chosen breakthrough will be added to the list, moved into spawner
	--UICity:SetTechResearched(bt) -- set if the chosen breakthrough will be instantly researched, moved into spawner
	return bt
end
--[[ =========== Finish:: Function to return a random Breakthrough  ========== --]]

--[[ =========== Start:: Function to return the resource type  ========== --]]

local function RD_GetResourceTypeFromDepositType(type)

	if RustyPrint then print ("deposit type passed into resource find",type) end

	if type == "BeautyEffectDeposit" then
		return "Beauty"
	elseif type == "ResearchEffectDeposit" then
		return "Research"
	elseif type == "TerrainDepositConcrete" then
		return "Concrete"
	elseif type == "SurfaceDepositsPolymers" then
		return "Polymers"
	elseif type == "SurfaceDepositsConcrete" then
		return "Concrete"
	elseif type == "SurfaceDepositsMetals" then
		return "Metals"
	elseif type == "SubSurfaceDepositsMetals" then
		return "Metals"
	elseif type == "SubSurfaceDepositsPreciousMetals" then
		return "PreciousMetals"
	elseif type == "SubSurfaceDepositsWater" then
		return "Water"
	--LukeH's resources, no need to comment out if it can't match them anyways
	elseif type == "SubsurfaceDepositCrystals" then
		return "Crystals"
	elseif type == "SubsurfaceDepositHydrocarbon" then
		return "Hydrocarbon"
	elseif type == "SubsurfaceDepositRadioactive" then
		return "Radioactive"

	else
		-- so if it is an anomaly then?
		if RustyPrint then print ("Non-resource deposit type passed into find resource function") end
		return ""
	end	
end
--[[ =========== Finish:: Function to return the resource type  ========== --]]

--[[ =========== Start:: Functions to randomise the deposit type  ========== --]]

local function RD_GetRandomEffectDepositType()
	local type = table.rand{
		"BeautyEffectDeposit",
		"ResearchEffectDeposit",
	}
	return type
end

local function RD_GetRandomSubSurfaceDepositType()
	local type = table.rand{
		"SubSurfaceDepositsMetals",
		"SubSurfaceDepositsPreciousMetals",
		"SubSurfaceDepositsWater",
		--LukeH's resources
		--"SubsurfaceDepositCrystals", 
		--"SubsurfaceDepositHydrocarbon",
		--"SubsurfaceDepositRadioactive",
	}
	return type
end

local function RD_GetRandomSurfaceDepositType()
	local type = table.rand{
		"SurfaceDepositsConcrete",
		"SurfaceDepositsMetals",
		"SurfaceDepositsPolymers",
	}
	return type
end

local function RD_GetRandomAnomalyType()
	local type = table.rand{
		"SubsurfaceAnomaly",
		"SubsurfaceAnomaly_breakthrough",
		"SubsurfaceAnomaly_aliens",
		"SubsurfaceAnomaly_unlock",
		"SubsurfaceAnomaly_complete",
	}
	return type
end
--[[ =========== Finish:: Functions to randomise the deposit type  ========== --]]

--[[ =========== Start:: Function to randomise the deposit type by marker class ========== --]]

local function RD_GetDepositTypeFromMarkerType(cls_obj)

	if RustyPrint then print ("class obj passed from marker type",cls_obj) end

	if cls_obj == "TerrainDepositMarker" then
		return "TerrainDepositConcrete"
	elseif cls_obj == "SubsurfaceAnomalyMarker" then
		return RD_GetRandomAnomalyType()
	elseif cls_obj == "SurfaceDepositMarker" then
		return RD_GetRandomSurfaceDepositType()
	elseif cls_obj == "SubsurfaceDepositMarker" then
		return RD_GetRandomSubSurfaceDepositType()
	elseif cls_obj == "EffectDepositMarker" then
		return RD_GetRandomEffectDepositType()
	else
		--just in case we somehow don't pass a valid type here?
		if RustyPrint then print ("Attempted to spawn a random deposit with an unkown class type") end
	end
end
--[[ =========== Finish:: Function to randomise the deposit type by marker class ========== --]]

--[[ =========== Start:: Function to Construct and Spawn a Random Deposit ========== --]]

local function RD_SpawnRandomDepositInSector(x,y,cls_obj)
	local city = UICity

	-- create a random point within the scanned sector
	local sector = g_MapSectors[x][y]--GetMapSectorXY(x, y)
	
	local minx, miny = sector.area:minxyz()		
	local maxx, maxy = sector.area:maxxyz()

	local pointx = city:Random(minx, maxx)
	local pointy = city:Random(miny, maxy)

	local pt = point(pointx, pointy,0)
	local pos = pt:SetTerrainZ() -- set it to the level of the terrain
	pos = HexGetNearestCenter(pos) -- snap it to the grid

	if RustyPrint then print("Spawn within Sector:",sector.display_name," at Position :",pos) end
	if RustyPrint then print ("type to create",cls_obj) end

	local dep_type = RD_GetDepositTypeFromMarkerType(cls_obj) -- find a random deposit type
	local res_type = RD_GetResourceTypeFromDepositType(dep_type) -- find the correct resource type

	local marker = PlaceObject(cls_obj)
	marker.deposit_type = dep_type   		-- the type of deposit, tied to the marker class
    marker.resource =   res_type 			-- the type of resource, tied to the deposit type
	
	-- randomize the details from the below choices
	local amount = table.rand{1000000,2500000,}
	marker.max_amount = amount         
	
	local grade = table.rand{"Very Low", "Low", "Average", "High", "Very High",}
	marker.grade = grade            
	
	local depth = table.rand{1,2,}
    marker.depth_layer = depth      
	
	-- other properties of the marker that pass along to the deposit
	marker.revealed = false
	marker.sequence_list = "Anomalies"
	marker.granted_resource = table.rand{"Metals","Food","PreciousMetals","Concrete","Fuel","Polymers","MachineParts","Electronics",}
	marker.granted_amount = marker.max_amount

	-- options for anomaly markers
	if marker.deposit_type == "SubsurfaceAnomaly" then 
		marker.sequence = RD_GetRandomAnomalySequence()
		marker.tech_action = ""
	elseif marker.deposit_type == "SubsurfaceAnomaly_breakthrough" then
		marker.breakthrough_tech = RD_GetRandomBreakthroughTech()
		--UICity:SetTechDiscovered(marker.breakthrough_tech) -- handled by default game code on scan
		--UICity:SetTechResearched(marker.breakthrough_tech) -- instantly research, too overpowered?
		marker.tech_action = "breakthrough"
	elseif marker.deposit_type == "SubsurfaceAnomaly_aliens" then
		UICity:SetTechResearched("AlienImprints") -- needed to be researched or alien imprints scanning rewards 0% boosts
		marker.sequence_list = "BreakthroughAlienArtifacts"
		marker.tech_action = "aliens"
	elseif marker.deposit_type == "SubsurfaceAnomaly_unlock" then
		marker.tech_action = "unlock"
	elseif marker.deposit_type == "SubsurfaceAnomaly_complete" then
		marker.tech_action = "complete"
	end

	--set the damn marker to the previously randomised position
	marker:SetPos(pos) -- forgot to do this for soooo long, couldn't figure out why it consistently spawned in J0 at 0,0,0.. duh!!

	--convert marker into a deposit
	local sector = GetMapSectorXY(pos:x(), pos:y())
	sector:RegisterDeposit(marker)
		marker.revealed = true
		local dep = marker:PlaceDeposit()
		dep:SetRevealed(true)
		dep:SetVisible(true)

	--this is such a long print, split it into lines on screen with \n but still needs to be one line here or throws an ERROR "Unfinished String"
	if RustyPrint then print ("A",dep.class,"was spawned and revealed with the following info ~~\n:: SECTOR ::",sector.display_name,"\n:: TYPE::",marker.deposit_type,"\n:: RES ::",marker.resource,"\n:: MAX ::",marker.max_amount,"\n:: GRADE ::",marker.grade,"\n:: DEPTH ::",marker.depth_layer,"\n:: SEQ ::",marker.sequence,"\n:: ACTION::",marker.tech_action) end
end
--[[ =========== Finish:: Function to randomise the deposit type by marker class ========== --]]

--[[ =========== Start:: Function to spawn a Random deposit PER SECTOR ========== --]]

function OnMsg.SectorScanned(status,x,y)

	local city = UICity
	local randomizer = city:Random(1,100) -- roll d%

	if RustyPrint then print ("A Sector was scanned, randomizer rolled::",randomizer) end

	if randomizer <= 20 then
		RD_SpawnRandomDepositInSector(x,y,"EffectDepositMarker")
	elseif randomizer >=21 and randomizer <= 40 then
		RD_SpawnRandomDepositInSector(x,y,"TerrainDepositMarker")
	elseif randomizer >=41 and randomizer <= 60 then
		RD_SpawnRandomDepositInSector(x,y,"SurfaceDepositMarker")
	elseif randomizer >=61 and randomizer <= 80 then
		RD_SpawnRandomDepositInSector(x,y,"SubsurfaceDepositMarker")
	elseif randomizer >=81 and randomizer <= 100 then
		RD_SpawnRandomDepositInSector(x,y,"SubsurfaceAnomalyMarker")
	end
end
--[[ =========== Finish:: Function to spawn a Random deposit PER SECTOR ========== --]]

--[[ =========== Finish:: More Location Bonuses : Random Spawn Per Sector Script:  ========== --]]
