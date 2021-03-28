--[[ =========== Start:: More Location Bonuses : Anomalies ========== --]]

local mod_name = "More_Location_Bonuses"
local steam_id = ""
-- local authors = "RustyDios"
-- local Version = "3"

--calling forth all script-wide global > locals
local ModDir = CurrentModPath
local RustyPrint = false

-- waiting until the map is good and loaded;
function OnMsg.MapSectorsReady()
    local TechFields = TechFields or {}
    if RustyPrint then print(":: Detected the following TechFields active",TechFields) end
end

-- cut down version of the spawner script, always reveals and pos ~ locked to the anom.pos
local function RD_Anoms_SpawnDeposit(pos,cls_obj,RD_Type,Res,Max,Grade,Depth)

    local pos = pos
    local pos_hex = WorldToHex(pos)
        pos = HexGetNearestCenter(pos)
    local x, y, z = pos:xyz()

    --the type of marker to drop    -- the deposits class type     -- and any marker variables that need to be set
    local marker = cls_obj:new()  
    marker.deposit_type = RD_Type   -- the type of deposit tied to the marker, see above note
    marker.resource = Res           -- the type of resource
    marker.revealed = true
    marker.max_amount = Max         -- maxium ammount of resource in deposit
    marker.grade = Grade            -- Grade of Deposit
    marker.depth_layer = Depth      -- depth layer, 1 is normal, 2 is deep
    
    marker:SetPos(pos)

	local sector = GetMapSectorXY(x, y)
		sector:RegisterDeposit(marker)
    local dep = marker:PlaceDeposit()
        dep:SetRevealed(true)
end-- end RD_Anoms_SpawnDeposit

-- using this msg function to alter the name & desc for our placed anomaly (visual is handled in the spawner by the tech_action set there...)
function OnMsg.AnomalyRevealed(self)

    local anom = self
    if RustyPrint then print("OnMsg fired:: Anomaly Revealed :: class",anom.class," :: seq :: ",anom.sequence," :: action :: ",anom.tech_action,":: list ::",anom.sequence_list) end
    
    -- swap the anom.sequence into the anom.tech_action to call from for the rest of the script, so default game doesn't try to start a non-existent Sequence Action
    if string.match(anom.sequence,"Rusty_TED") then  -- anomaly scans and spawns into a triboeffect deposit, no research point bonus
        --anom.display_name ("<color red>Rusty Anomaly</color>")
        anom.description = T("This <em><display_name></em> could be useful for our colony here on Mars. A strange electrical current fills the air.<newline><newline>Send an <em>Explorer</em> to analyze the Anomaly.")
        --here we blank out the sequence to skip over the default game code and get to the OnMsg.AnomalyAnalyzed where we can continue to hijack into the code with the newly copied tech_action :)
        anom.tech_action = anom.sequence  
        anom.sequence = ""

    elseif string.match(anom.sequence,"Rusty_Boost_%a") then -- one of each of the 10% tech boosts... research point bonus
        anom.description = T("This <em><display_name></em> could be useful for <em>boosting</em> our research efficiency.<newline><newline>Send an <em>Explorer</em> to analyze the Anomaly.")
        anom.tech_action = anom.sequence  
        anom.sequence = ""

    elseif string.match (anom.sequence,"Rusty_%a") then -- if a rusty anomaly but none of the special cases above... research point bonus 
        anom.description = T("This <em><display_name></em> could be useful for our colony here on Mars.<newline><newline>Send an <em>Explorer</em> to analyze the Anomaly.")
        anom.tech_action = anom.sequence  
        anom.sequence = ""

    end
    -- default tech_actions are false/"","breakthrough", "unlock","complete","resources", "aliens"
    -- "breakthrough" requires a valid anom.breakthrough_tech TechDef to be set, if no tech or already discovered it moves to unlock
    -- "unlock" reveals techs in the tree, if no techs left to reveal it moves to complete
    -- "complete" grants either 1000, 1250 or 1500 research points
    -- "resources" grants a stack of resources and requires anom.granted_resource to be a valid resource type and anom.granted_amount
    -- "aliens" gives the alien imprints notification and grants a cumulative 3% bonus to all tech fields
    -- anom.sequence lets us followup in the next section... 

end-- end anomaly revealed

--using this function to actually do stuff with the scanned site
function OnMsg.AnomalyAnalyzed(self)

    local anom = self
    local pos = anom:GetPos()
    if RustyPrint then print("OnMsg fired:: Anomaly Analyzed :: class",anom.class," :: seq :: ",anom.sequence," :: action :: ",anom.tech_action,":: list ::",anom.sequence_list,":: pos ::",pos) end

    --here we ensure that each Rusty Anom grants a default random research points in the same way the game does
    if string.match (anom.tech_action,"Rusty_%a") and not string.match (anom.tech_action,"Rusty_TED") then
        if RustyPrint then print("Analysed a rusty anom, set the tech action to complete, did we get rp?") end
        local points = anom:GrantRP(scanner) -- grants either 1000,1250 or 1500 res points to "UICity"
		if points then
			AddOnScreenNotification("GrantRP", nil, {points = points, resource = "Research"})
        end
    end

    --so here we can have/create an effect for each "sequence/tech_action" that we created in the spawn script and passed around using these on.msg manipulations
    if string.match (anom.tech_action,"Rusty_TED") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"TriboElectric Field"},
                        text = T{"Just as the explorer finishes it's scan the whole area starts humming and vibrating. The sensors start going haywire and then suddenly the air is filled with the soothing cyclic motions of a naturally formed TriboElectric Field.\n\n What type of sorcery is this? The area just needed an 'awakening' from our scanners."},
                        choice1 = T{"The anomaly is transformed into a natural TriboElectric Scrubbing Field"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"Accept the new field"},
                        choice1_rollover_title = T{"Anomaly is a TriboElectric Field"},
                        choice2 = T{"Purge the area immediately"},
                        choice2_rollover = T{"Destroy the new field"},
                        choice2_rollover_title = T{"Anomaly is a TriboElectric Field"},
                        choice2_img = "UI/CommonNew/message_box_cancel.tga",
                        image = ModDir.."/UI/RD_SA_TED.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        if RustyPrint then print ("You chose option 1 - do some more stuff") end
                        RD_Anoms_SpawnDeposit(pos,EffectDepositMarker,"TriboEffectDeposit",nil,nil,nil,1)
                    elseif choice == 2 then
                        if RustyPrint then print ("you chose option 2 - dismiss") end
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Beryllium") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},         -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Beryllium !!"},
                        text = T{"Beryllium. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>Physics</em> research.<newline><newline><em>Effect:</em> Reduces the cost of Physics techs by 10%."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field."},
                        choice1_rollover_title = T{"Rusty Beryllium discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Beryllium.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        UICity.TechBoostPerField["Physics"] = (UICity.TechBoostPerField["Physics"] or 0) + 10
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Tellurium") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga",  -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Tellurium !!"},
                        text = T{"Tellurium. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>Robotics</em> research.<newline><newline><em>Effect:</em> Reduces the cost of Robotics techs by 10%."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field."},
                        choice1_rollover_title = T{"Rusty Tellurium discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Tellurium.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        UICity.TechBoostPerField["Robotics"] = (UICity.TechBoostPerField["Robotics"] or 0) + 10
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Sulphides") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Sulphides !!"},
                        text = T{"Sulphides. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>Engineering</em> research.<newline><newline><em>Effect:</em> Reduces the cost of Engineering techs by 10%."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field."},
                        choice1_rollover_title = T{"Rusty Sulphides discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Sulphides.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        UICity.TechBoostPerField["Engineering"] = (UICity.TechBoostPerField["Engineering"] or 0) + 10
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Germanium") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Germanium !!"},
                        text = T{"Germanium. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>Social</em> research.<newline><newline><em>Effect:</em> Reduces the cost of Social techs by 10%."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field."},
                        choice1_rollover_title = T{"Rusty Germanium discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Germanium.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        UICity.TechBoostPerField["Social"] = (UICity.TechBoostPerField["Social"] or 0) + 10
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Americium") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Americium !!"},
                        text = T{"Americium. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>BioTech</em> research.<newline><newline><em>Effect:</em> Reduces the cost of BioTech techs by 10%."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field."},
                        choice1_rollover_title = T{"Rusty Americium discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Americium.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        UICity.TechBoostPerField["Biotech"] = (UICity.TechBoostPerField["Biotech"] or 0) + 10
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Nobelium") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Nobelium !!"},
                        text = T{"Nobelium. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>Terraforming</em> research.<newline><newline>If Terraforming is not availible on Mars yet you will get a 5% boost to all fields.<newline><newline><em>Effect:</em> Reduces the cost of Terraforming techs by 10% or grants a 5% reduction to all techs."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field.<newline> OR <em>5%</em> boost to all fields."},
                        choice1_rollover_title = T{"Rusty Nobelium discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Nobelium.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        if TechFields.Terraforming then
                            UICity.TechBoostPerField["Terraforming"] = (UICity.TechBoostPerField["Terraforming"] or 0) + 10
                        else
                            for field in pairs(TechFields) do
                                UICity.TechBoostPerField[field] = (UICity.TechBoostPerField[field] or 0) + 5
                            end
                        end
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Einsteinium") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Einsteinium !!"},
                        text = T{"Einsteinium. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>Breakthroughs</em> research.<newline><newline><em>Effect:</em> Reduces the cost of Breakthrough techs by 10%."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field."},
                        choice1_rollover_title = T{"Rusty Einsteinium discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Einsteinium.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        UICity.TechBoostPerField["Breakthroughs"] = (UICity.TechBoostPerField["Breakthroughs"] or 0) + 10
                        UICity.TechBoostPerField["Mysteries"] = (UICity.TechBoostPerField["Mysteries"] or 0) + 10
                        UICity.TechBoostPerField["Storybits"] = (UICity.TechBoostPerField["Storybits"] or 0) + 10 
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

    if string.match (anom.tech_action,"Rusty_Boost_Silver") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"Silver !!"},
                        text = T{"Silver. You just found a huge <em>rusty</em> chunk of the stuff.<newline><newline>This will really help our <em>SilvaTech</em> research.<newline><newline>If SilvaTech is not availible on Mars yet you will get a 5% boost to all fields.<newline><newline><em>Effect:</em> Reduces the cost of SilvaTech techs by 10% or grants a 5% reduction to all techs."},
                        choice1 = T{"Shiny !!"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"An amazing resource has been discovered.<newline> <em>10% </em>boost to the indicated research field.<newline> OR <em>5%</em> boost to all fields."},
                        choice1_rollover_title = T{"Rusty Silver discovered"},
                        image = ModDir .. "/UI/RD_SA_B_Silver.dds",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        if TechFields.RDM_SilvaTech then
                            UICity.TechBoostPerField["RDM_SilvaTech"] = (UICity.TechBoostPerField["RDM_SilvaTech"] or 0) + 10
                        else
                            for field in pairs(TechFields) do
                                UICity.TechBoostPerField[field] = (UICity.TechBoostPerField[field] or 0) + 5
                            end
                        end
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

end--end OnMSg Anom Analyzed

--[[@@@
Display a custom on-screen notification.
@function void AddCustomOnScreenNotification(string id, string title, string text, string image, function callback, table params)
@param string id - unique identifier of the notification.
@param string title - title of the notification.
@param string text - body text of the notification.
@param string image - path to the notification icon.
@param function callback - optional. Function called when the user clicks the notification.
@param table params - optional. additional parameters.
Additional parameters are supplied to the translatable texts, but can also be used to tweak the functionality of the notification:
- _'cycle_objs'_ will cause the camera to cycle through a list of _GameObjects_ or _points_ when the user clicks the notification.
- _'priority'_ changes the priority of the notification (choose between _"Normal"_, _"Important"_ and _"Critical"_; default=_"Normal"_).
- _'dismissable'_ dictates the dismissability of the notification (default=_true_)
- _'close_on_read'_ will cause the notification to disappear when the user clicks on it (default=_false_).
- _'expiration'_ is the amount of time (in _milliseconds_) that the notification will stay on the screen (default=_-1_).
- _'game_time'_ decides if the expiration countdown is done in _RealTime_ or _GameTime_ (default=_false_).
- _'display_countdown'_ must be _true_ if the _expiration_ countdown will be displayed in the notification texts (will be formatted and supplied to the translatable texts as _'countdown'_ parameter; this requires _'game_time'_ to be _true_).
]]

--[[
    --so here we can have/create an effect for each "sequence/tech_action" that we created in the spawn script and passed around using these on.msg manipulations
    if string.match (anom.tech_action,"Rusty_%a") then
        if RustyPrint then print("Analysed a Rusty Anom :: ",anom.tech_action) end

        AddCustomOnScreenNotification(anom.tech_action,
            T{"Anomaly Analyzed"},     -- title of popup note
            T{"View Message"},      -- info text
            "UI/Icons/Notifications/New/placeholder_2.tga", -- icon
            function() 
                CreateRealTimeThread(function()
                    local params = {
                        title = T{"BigPopUp Title"},
                        text = T{"BigPopUp Body Text"},
                        choice1 = T{"Choice1 text"},
                        choice1_img = "UI/CommonNew/message_box_ok.tga",
                        choice1_rollover = T{"Choice1 rollover"},
                        choice1_rollover_title = T{"choice1 rollover title"},
                        choice1_hint1 = T{"choice1 hint 1 -left"},
                        choice1_hint2 = T{"choice1 hint 2 - right"},
                        choice2 = T{"Choice2 text etc, repeat for however many needed, kinda max at 4"},
                        choice2_img = "UI/CommonNew/message_box_cancel.tga",
                        image = "UI/Messages/hints.tga",
                        start_minimized = false,
                    } -- params
                    local choice = WaitPopupNotification(false, params)
                    if choice == 1 then
                        if RustyPrint then print ("You chose option 1 - done some more stuff") end
                        -- more stuff code here...
                    elseif choice == 2 then
                        if RustyPrint then print ("you chose option 2 - dismiss") end 
                    end
                end ) -- CreateRealTimeThread
            end,-- function called on click
            {
                expiration = -1,
                priority = "Critical",-- "Normal",blue  --"Important",red   --"Critical",red flashing
                dismissable = false,
                close_on_read = true,
            }
        )--end on screen pop up        
        PlayFX("UINotificationResearchComplete")

    end-- string.match

]]