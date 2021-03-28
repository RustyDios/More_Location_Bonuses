--[[ =========== Start:: More Location Bonuses : Main Script: Bonus Deposits Spawner ========== --]]
-- this mod is designed to ADD MORE Dome Bonus areas to a map, it will also add these areas to the Mod Editor Map

local mod_name = "More_Location_Bonuses"
local steam_id = ""
-- local authors = "RustyDios, ChoGGi"
-- local Version = "15"

local RustyPrint = false

--[[ =========== Start:: Function to add more deposits ========== --]]

local function RD_AddNewDeposit(cls_obj,RD_Type,Res,Rev,Max,Grade,Depth,Seq,SeqAction,SeqList)

    --get a random passable position on the map and of equal level to the ground
    local pos = GetRandomPassablePoint(AsyncRand()):SetTerrainZ(15)
    local pos_hex = WorldToHex(pos)
    local x, y, z = pos:xyz()
    --local range = HexGridGetObjectsInRange(ObjectGrid,pos_hex,1)

    --the type of marker to drop    -- the deposits class type     -- and any marker variables that need to be set
    local marker = cls_obj:new()  
    marker.deposit_type = RD_Type   -- the type of deposit tied to the marker, see above note
    marker.resource = Res           -- the type of resource
    marker.revealed = false
    marker.max_amount = Max         -- maxium ammount of resource in deposit
    marker.grade = Grade            -- Grade of Deposit
    marker.depth_layer = Depth      -- depth layer, 1 is normal, 2 is deep
    
    -- options for anomaly markers
    marker.sequence = Seq or ""                     -- used if the marker is to spawn an anomaly, see list below of default game types
	marker.sequence_list = SeqList or "Anomalies"   -- OR "BreakthroughAlienArtifacts" OR "Expeditions" OR "Mystery_1" - "Mystery_9"
    marker.tech_action = SeqAction                  -- blank           :: Anomaly_01 :: Eye
                                                    -- "breakthrough"  :: Anomaly_02 :: Mag Glass        
                                                    -- "aliens"        :: Anomaly_03 :: Signals
                                                    -- "unlock"        :: Anomaly_04 :: Key
                                                    -- "complete"      :: Anomaly_05 :: Tech Bottle
    
    marker.Rusty_Extra = true -- a way to see on ChoGGi's > ECM > Examine if a deposit was spawned by this code,, F4/Examine > marker,, it won't transfer to the deposit?

    --move it to the previous spawned random location but snapped to the grid, still to code loop for checking obstructions :)
    pos = HexGetNearestCenter(pos)
    --if not range then
        marker:SetPos(pos)
    --end

	local sector = GetMapSectorXY(x, y)
	if sector then
		sector:RegisterDeposit(marker)
        -- if Revealed was set true in the function call, reveal the deposit
        if Rev then
            marker.revealed = true
            local dep = marker:PlaceDeposit()
            dep:SetRevealed(true)
            if RustyPrint then print(":: Extra",marker.deposit_type,":: Revealed in sector ::",sector.display_name,"::") end    -- console log print used to aid debugging
        else
            --if RustyPrint then print(":: Extra",marker.deposit_type,":: Hidden in sector ::",sector.display_name,"::") end      -- console log print used to aid debugging
        end
	else
		if RustyPrint then print(":: NO SECTOR for extra deposit - HOW? ::",sector.display_name,"::") end                       -- console log print used to aid debugging, should never appear
	end
end

--[[ =========== Finish:: Functions to add more deposits ========== --]]

--[[ =========== Start:: Functions to grab a random anomaly sequence ========== --]]

local function GetRandomAnomalySequence()
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

    if RustyPrint then print ("The above random SA was chosen to be",Seq) end

    return Seq
end
--[[ =========== Finish:: Functions to grab a random anomaly sequence ========== --]]

--[[ =========== Start:: Add MORE Deposits to map ========== --]]
local function StartupCode()
    -- include this line to only fire the script once per city start or per load game
	if not UICity.RD_MoreLocationBonusesSetup then

            --yes this is a minefield of upper and lower case going wrong !! hence why I put them here in comments to copy :)
            local EffectDepositMarker = EffectDepositMarker         -- types = "BeautyEffectDeposit",Beauty             :: "ResearchEffectDeposit",Research                     :: "TriboEffectDeposit"
            local TerrainDepositMarker = TerrainDepositMarker       -- types = "TerrainDepositConcrete","Concrete"
            local SurfaceDepositMarker = SurfaceDepositMarker       -- types = "SurfaceDepositsConcrete","Concrete"     :: "SurfaceDepositsMetals","Metals"                     :: "SurfaceDepositsPolymers","Polymers"
            local SubsurfaceDepositMarker = SubsurfaceDepositMarker -- types = "SubSurfaceDepositsMetals","Metals"      :: "SubSurfaceDepositsPreciousMetals","PreciousMetals"  :: "SubSurfaceDepositsWater","Water"
            --LukeH's resources                                     -- types = "SubsurfaceDepositCrystals","Crystals"   :: "SubsurfaceDepositHydrocarbon","Hydrocarbon"         :: "SubsurfaceDepositRadioactive","Radioactive"
            local SubsurfaceAnomalyMarker = SubsurfaceAnomalyMarker -- types =  "SubsurfaceAnomaly",""(blank)         ~~ Anomaly_01 :: Eye/Examine/Action Spot/Sequence
                                                                    --          "SubsurfaceAnomaly","breakthrough"    ~~ Anomaly_02 :: Mag Glass/Breakthough        
                                                                    --          "SubsurfaceAnomaly","aliens"          ~~ Anomaly_03 :: Signals/Alien Imprints
                                                                    --          "SubsurfaceAnomaly","unlock"          ~~ Anomaly_04 :: Key/Unlock Techs
                                                                    --          "SubsurfaceAnomaly","complete"        ~~ Anomaly_05 :: Research Bottle/Points only/Meteor Impact
            
            --i initial value is the number of bonus spots to add 1 = "minimum 1", total_to_add
            for i = 1, 5  do
                RD_AddNewDeposit(EffectDepositMarker,"BoostedVistaDeposit",nil,false,nil,nil,1)     -- add 5 Boosted Vistas across the map, boosted has a random comfort
            end
            for i = 1, 5  do
                RD_AddNewDeposit(EffectDepositMarker,"ResearchEffectDeposit",nil,false,nil,nil,1)   -- keeping it seperated JUST to make the log look all pretty, if prints are on :) 
            end

            for i = 1, 9  do   -- add my own anomalies!!   -- adding *10* of these is roughly good for most maps, see freebie below
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_TED","aliens")       
            end

            for i = 1, 1  do   -- add my own anomalies!!   -- adding *10* of these is roughly good for most maps, freebie below
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,true,nil,nil,1,"Rusty_TED","aliens")       
            end

            for i = 1, 1  do    -- add my own anomalies!!   -- one of each type of 10% boost for all tech fields
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Beryllium")    -- Physics  
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Tellurium")    -- Robotics     
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Sulphides")    -- Engineering  
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Germanium")    -- Social
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Americium")    -- BioTech
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Nobelium")     -- Terraforming or 5% all
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Einsteinium")  -- Breakthroughs! Mysteries! Storybits!        
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Rusty_Boost_Silver")       -- SilvaTech!(id = "RDM_SilvaTech") or 5% all       
            end 

            for i =1, 1  do                
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,"Stuning Vista")           -- add the anomaly that grants a celeb, me-lol, and a Vista  
                RD_AddNewDeposit(SubsurfaceAnomalyMarker,"SubsurfaceAnomaly",nil,false,nil,nil,1,GetRandomAnomalySequence())-- add a random anomaly
            end 

            --[[    
                RD_AddNewDeposit(classs_obj,deposit_type,Resource,Revealed,Max Ammount,Grade,Depth,Seq,SeqAction,SeqList)
                    --Resource :: must match the type of deposit,
                    --Revealed :: true or false
                    --Ammount :: number000, eg 69 metals is 69000 .. surface metals are limited to random group size .. regolith ammount also changes terrain texture/proportionally (more testing needed)
                    --Grades :: "Very Low", "Low", "Average", "High", "Very High"
                    --Depth :: 1 shallow, 2 deep (core deposits are deep)
                    --Seq :: optional field required for anomalies to determine what to do, can be random, precise or left blank -- see random list above
                    --SeqAction :: override to change the visual appearance of the anomaly, see types above
                    --SeqList :: override if a custom anomaly list is to be checked .. ??maybe functional??
            --]]

    UICity.RD_MoreLocationBonusesSetup = true
    end
end

--place entities on start of a new map
function OnMsg.CityStart()
	CreateRealTimeThread(function()
		-- wait till the map is good n loaded
		WaitMsg("MapSectorsReady")
		StartupCode()
	end)
end

--place entities on load of a map >= savegame compatable
OnMsg.LoadGame = StartupCode

--[[ =========== Finish:: Add MORE Deposits to map ========== --]]

--[[ =========== Finish:: More Location Bonuses : Main Script: Bonus Deposits Spawner ::========== --]]
