--[[ =============== :: Start: More Location Bonuses: Construction Status' Override  ============== ]]

local mod_name = "More_Location_Bonuses"
local steam_id = ""
-- local authors = "RustyDios"
-- local Version = "42+, lol"

local RustyPrint = false

if RustyPrint then print  ("More Location Bonuses:: Updating Construction Controller Status with code from RustyDios") end
ModLog ("More Location Bonuses:: Updating Construction Controller Status with code from RustyDios")

--[[ =============== :: Start: Construction Status' Override Function ============== ]]

--store the original function and start ours... note the (...) so we don't care what other functions might pass in, we pass it all on
local RD_Override_ConstructionController_UpdateConstructionStatuses = ConstructionController.UpdateConstructionStatuses
function ConstructionController:UpdateConstructionStatuses(...)

	--start running the construction status loop by using the old script
	RD_Override_ConstructionController_UpdateConstructionStatuses(self,...)

	local obj = GetTerrainCursor()
   	--find nearby tribo effect effect deposits relative to the current cursor position
	local obj_hex_pos = WorldToHex(GetTerrainCursor(pos))
	local pos = HexToWorld(obj_hex_pos)
	local nearest = MapFindNearest("map",pos,"TriboEffectDeposit",function(o) return o end)
	if IsValid(nearest) then 
		local nearest_hex_pos = WorldToHex(nearest:GetPos())
		local nearest_range = nearest:GetSelectionRadiusScale()
	
		-- print out the information we just gathered to check it in game
		if RustyPrint then print("self.template_obj.class",self.template_obj.class,"cursor hex",obj_hex_pos) end
		if RustyPrint then print("nearest found",nearest.class,"with a range of",nearest_range,"nearest_hex pos",nearest_hex_pos) end
		if RustyPrint then print("hex dist",HexAxialDistance(GetTerrainCursor(),nearest)) end

		if HexAxialDistance(GetTerrainCursor(),nearest) <= nearest_range  then
			if RustyPrint then print("we're in range to do the cool stuff") end
			self.construction_statuses[#self.construction_statuses + 1] = ConstructionStatus.TriboDepositNearby
		end
	end
    -- don't finalise the loop yet, keep searching for more status' OR finalise it
	if not dont_finalize then
		self:FinalizeStatusGathering(old_t)
	else
		return old_t
	end
end

--[[ =============== :: Finish: Construction Status' Override Function  ============== ]]

--[[ =============== :: Finish: More Location Bonuses: Construction Status' Override  ============== ]]
