--[[ =============== :: Start: More Location Bonuses: Deposits: Altered Class: BoostedVistaDeposit ============== ]]

local mod_name = "More_Location_Bonuses"
local steam_id = ""
-- local authors = "RustyDios"
-- local Version = "3"

local RustyPrint = false

--[[ =============== :: Start: Define and init BoostedVistaDeposit :: ============== ]]

    DefineClass.BoostedVistaDeposit = {
	__parents = { "BeautyEffectDeposit" },
	
	building_class = "Dome",
	modifier = false,
    comfort_increase = 10 ,
    comfort_increase_options = {-10,10,20,30},
	
	ConstructionStatusName = "BeautyDepositNearby",
	resource = "Beauty",
	display_name = "Vista",
	IPDescription = "Improves the comfort of all residences when in the radius of a Dome.",
	display_icon = "UI/Icons/bmb_demo.tga",
	entity = "SignDomeBonusVista",
}

function BoostedVistaDeposit:Init()
    self.encyclopedia_id = "Colonist"
    -- randomise the comfort increase, for better or worse
    self.comfort_increase = table.rand(self.comfort_increase_options)
    if RustyPrint then print ("A boosted Vista had a comfort of",self.comfort_increase) end

    --alter the infopanel display name based on the new outcome, default 10 stays at "Vista"
    if self.comfort_increase < 10 then      
        self.display_name = "<color red>Wasteland View</color>"    --it's a -10 vista
    end

    if self.comfort_increase > 10 then
        self.display_name = "<color green>Beautiful Vista</color>"   -- its a 20 or 30 vista, bump up the name
    end

    if self.comfort_increase > 20 then
        self.display_name = "<color em>Vibrant Vista</color>"    -- its a 30 vista, bump the name again
    end

    -- set the comfort_increase to the scale of the map, default behavior for the standard vista
    self.comfort_increase = self.comfort_increase * const.Scale.Stat

    -- create the dome modifier
	self.modifier = Modifier:new{
		prop = "dome_comfort",
		amount = self.comfort_increase ,
		percent = 0,
		id = "Beauty Effect Deposit",
    }

    --after modifying change the class back to just a standard effect deposits so that all the functions/constructions sums stuff works
    --can't believe this actually worked :)
    self.class = "BeautyEffectDeposit"
end

--[[ =============== :: Finish: Define and init BoostedVistaDeposit :: ============== ]]

--[[ =============== :: Finish: More Location Bonuses: Deposits: Altered Class: BoostedVistaDeposit ============== ]]
